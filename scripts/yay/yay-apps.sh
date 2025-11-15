#!/bin/bash
# Instalação de apps AUR usando yay

set -e

AUR_PACKAGES=(
    windscribe-v2-bin
    localsend-bin
    android-studio
    visual-studio-code-bin
)

echo "======================================"
echo " 🚀 Instalando apps AUR selecionados"
echo "======================================"

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo
echo "✔ Instalação concluída!"
