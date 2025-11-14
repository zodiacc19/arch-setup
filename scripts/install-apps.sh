#!/bin/bash
# ============================================================
# 💻 Instalação automatizada de programas no Arch Linux (KDE)
# ------------------------------------------------------------
# - Instala pacotes via pacman e AUR
# - Detecta yay ou paru (instala yay se necessário)
# - Mantém execução segura e limpa
# ============================================================

set -e

# Cores
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Lista de pacotes oficiais (pacman)
PACMAN_PKGS=(
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-dejavu
  inter-font
  okular
  gwenview
  reaper
  elisa
  kdenlive
  gimp
  krita
  inkscape
  qbittorrent
  discord
  telegram-desktop
  thunderbird
  partitionmanager
  filelight
  keepassxc
  kalk
  gufw
  exfatprogs
  ntfs-3g
  lutris
  wine
  winetricks
  wine-mono
  wine-gecko

  # --- CODECS COMPLETOS ---
  ffmpeg
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  gst-libav
  x264
  x265
  libdvdcss
  libdvdread
  libdvdnav
)

# Lista de pacotes do AUR (vazia por enquanto)
AUR_PKGS=(
)

# Verifica se é root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}⚠️  Por favor, execute como root:${RESET}"
   echo "sudo $0"
   exit 1
fi

echo -e "${YELLOW}🔄 Atualizando o sistema...${RESET}"
pacman -Syu --noconfirm || { echo -e "${RED}❌ Falha ao atualizar o sistema.${RESET}"; exit 1; }

echo -e "${YELLOW}📦 Instalando pacotes oficiais...${RESET}"
pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"

echo -e "${YELLOW}🔍 Verificando gerenciador AUR (yay ou paru)...${RESET}"
if command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
else
  echo -e "${YELLOW}⚠️ Nenhum helper AUR encontrado. Instalando yay...${RESET}"
  pacman -S --noconfirm git base-devel
  runuser -u "$(logname)" -- bash << 'EOF'
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
EOF
  AUR_HELPER="yay"
fi

echo -e "${GREEN}🎯 Usando AUR helper: $AUR_HELPER${RESET}"

if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
  echo -e "${YELLOW}🌐 Instalando pacotes do AUR...${RESET}"
  runuser -u "$(logname)" -- $AUR_HELPER -S --noconfirm --needed "${AUR_PKGS[@]}"
fi

echo -e "${GREEN}✅ Tudo instalado com sucesso!${RESET}"
