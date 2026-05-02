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
  # Fontes
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-dejavu
  inter-font
  
  # Sistema / Base
  power-profiles-daemon
  exfatprogs
  ntfs-3g
  net-tools
  speech-dispatcher
  btop

  # Apps KDE
  bazaar
  kdenlive
  okular
  gwenview
  korganizer
  kcalc
  filelight
  partitionmanager
  elisa

  # Shells 
  fish
  fzf
  eza
  less
  zoxide
  starship
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting

  # Desenvolvimento / Programação  
  jdk11-openjdk
  jdk-openjdk
  rust
  php
  lazygit
  nodejs
  nvm
  npm
  typescript
  neovim

  # Containers / DevOps
  docker
  docker-compose
  lazydocker
  kubectl
  minikube
  helm

  # Segurança / Hacking
  nmap
  hydra
  openbsd-netcat
  wireshark-qt
  metasploit
  veracrypt
  keepassxc
  whois
  
  # Navegadores
  chromium
  torbrowser-launcher
  
  # Comunicação
  discord
  telegram-desktop
  
  # Bancos de dados
  postgresql

  # Design / Multimídia
  gimp
  inkscape
  krita

  # Áudio / Vídeo
  audacity
  termusic
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

  # Virtualização
  virtualbox
  virtualbox-host-modules-arch
  virtualbox-guest-iso

  # Emulação / Wine
  wine
  wine-mono
  wine-gecko
  winetricks

  # Downloads / Torrent
  qbittorrent

  # IA
  ollama
  gemini-cli
)

# Lista de pacotes do AUR
AUR_PKGS=(
  localsend-bin
  windscribe-v2-bin
  visual-studio-code-bin
  virtualbox-ext-oracle
  brave-bin
  caido-desktop
  goanime
  jetbrains-toolbox
  gitkraken
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
