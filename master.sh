#!/bin/bash
# script_mestre.sh — executa scripts como root e scripts yay como usuário

set -e  # Para parar se ocorrer erro

# ---------------- Cores ----------------
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# ---------- Diretório real do script ----------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# --------------- Pré-ajustes ----------------

# Converte scripts criados no Windows (CRLF → LF)
if command -v dos2unix >/dev/null 2>&1; then
    find "$BASE_DIR/scripts" -type f -name "*.sh" -exec dos2unix {} \; 2>/dev/null || true
fi

# --------------- Funções ----------------

print_section() {
    echo -e "\n${BLUE}====================================================${RESET}"
    echo -e "${YELLOW}$1${RESET}"
    echo -e "${BLUE}====================================================${RESET}\n"
}

# Executa script como root ou como usuário normal
run_script() {
    local script_name=$1
    local mode=$2  # "user" ou vazio

    print_section "Executando: $script_name"

    # Executar como usuário normal
    if [[ "$mode" == "user" ]]; then
        if [[ -z "$SUDO_USER" ]]; then
            echo -e "${RED}✖ ERRO: Rode este script usando sudo!${RESET}"
            exit 1
        fi

        echo -e "${YELLOW}⚠ Executando como usuário: $SUDO_USER${RESET}"

        if sudo -u "$SUDO_USER" bash "$script_name"; then
            echo -e "${GREEN}✔ $script_name concluído com sucesso!${RESET}\n"
        else
            echo -e "${RED}✖ Erro ao executar $script_name${RESET}\n"
            exit 1
        fi

    # Executar como root
    else
        if bash "$script_name"; then
            echo -e "${GREEN}✔ $script_name concluído com sucesso!${RESET}\n"
        else
            echo -e "${RED}✖ Erro ao executar $script_name${RESET}\n"
            exit 1
        fi
    fi
}

# ---------------- Execução Principal ----------------

clear
echo -e "${GREEN}🌟 Iniciando execução dos scripts...${RESET}"

# 1️⃣ Scripts que rodam como root
run_script "$BASE_DIR/scripts/install.apps.sh"
run_script "$BASE_DIR/scripts/setup-auto-exfat.sh"

# 2️⃣ Scripts que usam yay (executados como usuário normal)
run_script "$BASE_DIR/scripts/yay/docker-in.sh" user
# run_script "$BASE_DIR/scripts/yay/yay-apps.sh" user

print_section "✅ Todos os scripts foram executados com sucesso!"