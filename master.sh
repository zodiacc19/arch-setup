#!/bin/bash
# script_mestre.sh — executa três scripts em sequência

# Parar o script se qualquer comando falhar
set -e

# Cores para o terminal
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Função para mostrar cabeçalhos bonitos
print_section() {
    echo -e "\n${BLUE}====================================================${RESET}"
    echo -e "${YELLOW}$1${RESET}"
    echo -e "${BLUE}====================================================${RESET}\n"
}

# Função para executar e exibir status
run_script() {
    local script_name=$1
    print_section "Executando: $script_name"
    if bash "$script_name"; then
        echo -e "${GREEN}✔ $script_name concluído com sucesso!${RESET}\n"
    else
        echo -e "${RED}✖ Erro ao executar $script_name${RESET}\n"
        exit 1
    fi
}

clear
echo -e "${GREEN}🌟 Iniciando execução dos scripts...${RESET}"

run_script "install-apps.sh"
run_script "setup-auto-exfat.sh"

print_section "✅ Todos os scripts foram executados com sucesso!"
