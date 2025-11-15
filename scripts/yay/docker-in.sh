#!/bin/bash
# ============================================================
# 🐳 Instalação automatizada do Docker Desktop no Arch Linux
# ------------------------------------------------------------
# - Instala Docker Desktop via AUR (yay)
# - Usa qemu-base
# - Remove qualquer autostart do desktop
# - Desativa serviço + socket
# - Adiciona usuário ao grupo docker
# ============================================================

set -e  # Pare em qualquer erro

echo "🚀 Instalando Docker Desktop no Arch Linux..."

# Garante que o script está rodando como bash
if [ -z "$BASH_VERSION" ]; then
    echo "Re-executando com bash..."
    exec bash "$0" "$@"
fi

# Valida yay
if ! command -v yay &> /dev/null; then
    echo "❌ 'yay' não encontrado. Instale-o antes de rodar o script."
    exit 1
fi

# Pega o usuário real mesmo dentro de setups automatizados
REAL_USER="${SUDO_USER:-$USER}"

echo "📦 Instalando Docker Desktop + qemu-base..."
yay -S --noconfirm --needed docker-desktop qemu-base

echo "🔧 Desabilitando serviços..."
systemctl --user disable docker-desktop.service 2>/dev/null || true
systemctl --user disable docker-desktop.socket 2>/dev/null || true
systemctl --user stop docker-desktop.service 2>/dev/null || true
systemctl --user stop docker-desktop.socket 2>/dev/null || true

# Remove autostart criado pelo pacote
echo "🧹 Removendo autostart..."
rm -f "/home/$REAL_USER/.config/autostart/docker-desktop.desktop" 2>/dev/null || true

# Adiciona ao grupo docker
echo "👤 Adicionando '$REAL_USER' ao grupo docker..."
sudo usermod -aG docker "$REAL_USER"

echo ""
echo "✅ Docker Desktop instalado e autostart desativado!"
echo "🔁 Faça logout/login ou reinicie para ativar o grupo docker."
echo ""
echo "▶️ Para iniciar manualmente:"
echo "    systemctl --user start docker-desktop"
echo ""
echo "🐋 Testar Docker:"
echo "    docker run hello-world"