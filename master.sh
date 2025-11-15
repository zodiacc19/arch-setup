#!/bin/bash
set -e

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

if command -v dos2unix >/dev/null 2>&1; then
    find "$BASE_DIR/scripts" -type f -name "*.sh" -exec dos2unix {} \; 2>/dev/null || true
fi

print_section() {
    echo -e "\n${BLUE}====================================================${RESET}"
    echo -e "${YELLOW}$1${RESET}"
    echo -e "${BLUE}====================================================${RESET}\n"
}

run_script() {
    local script=$1
    local mode=$2

    print_section "Executando: $script"

    if [[ "$mode" == "user" ]]; then
        if [[ -z "$SUDO_USER" ]]; then
            echo -e "${RED}✖ Rode com sudo!${RESET}"
            exit 1
        fi

        sudo -u "$SUDO_USER" bash "$script"
    else
        bash "$script"
    fi
}

clear
echo -e "${GREEN}🌟 Iniciando execução dos scripts...${RESET}"

run_script "$BASE_DIR/scripts/install.apps.sh"
run_script "$BASE_DIR/scripts/setup-auto-exfat.sh"

run_script "$BASE_DIR/scripts/yay/docker-in.sh" user

print_section "✅ Todos os scripts foram executados com sucesso!"