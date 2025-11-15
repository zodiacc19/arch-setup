#!/bin/bash
# script_mestre.sh — executa scripts como root e scripts yay como usuário

set -e  # Para execução se algo der errado

# ---------------- Cores ----------------
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# --------------- Funções ----------------

print_section() {
    echo -e "\n${BLUE}====================================================${RESET}"
    echo -e "${YELLOW}$1${RESET}"
    echo -e "${BLUE}====================================================${RESET}\n"
}

# Executa script como root ou usuário normal
run_script() {
    local script_name=$1
    local mode=$2  # "user" ou vazio

    print_section "Executando: $script_name"

    # Caso o script precise rodar como usuário normal
    if [[ "$mode" == "user" ]]; then
        if [[ -z "$SUDO_USER" ]]; then
            echo -e "${RED}✖ ERRO: Este script deve ser executado usando sudo.${RESET}"
            exit 1
        fi

        echo -e "${YELLOW}⚠ Executando como usuário: $SUDO_USER${RESET}"

        if sudo -u "$SUDO_USER" bash "$script_name"; then
            echo -e "${GREEN}✔ $script_name concluído com sucesso!${RESET}\n"
        else
            echo -e "${RED}✖ Erro ao executar $script_name${RESET}\n"
            exit 1
        fi

    # Caso seja script root
    else
        if bash "$script_name"; then
            echo -e "${GREEN}✔ $script_name concluído com sucesso!${RESET}\n"
        else
            echo -e "${RED}✖ Erro ao executar $script_name${RESET}\n"
            exit 1
        fi
    fi
}

# ---------------- Execução ----------------

clear
echo -e "${GREEN}🌟 Iniciando execução dos scripts...${RESET}"

# 1️⃣ Scripts que rodam como root
run_script "scripts/install.apps.sh"
run_script "scripts/setup-auto-exfat.sh"

# 2️⃣ Script que contém yay (roda como usuário)
run_script "scripts/yay/docker-in.sh" user

print_section "✅ Todos os scripts foram executados com sucesso!"
