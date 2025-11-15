#!/bin/bash
# ============================================================
# 🐳 Instalação automatizada do Docker Desktop no Arch Linux
# ------------------------------------------------------------
# - Instala Docker Desktop via AUR (yay)
# - Usa qemu-base
# - Remove qualquer autostart do desktop
# - Desativa serviço + socket
# - Remove autostart oculto do Electron
# - Corrige settings.json (autoStart false)
# - Mata processos org.chromium.chrome iniciados automaticamente
# - Adiciona usuário ao grupo docker
# ============================================================

set -e  # Pare em qualquer erro

echo "🚀 Instalando Docker Desktop no Arch Linux..."

# Garante bash
if [ -z "$BASH_VERSION" ]; then
    echo "Re-executando com bash..."
    exec bash "$0" "$@"
fi

# Verifica yay
if ! command -v yay &> /dev/null; then
    echo "❌ 'yay' não encontrado. Instale-o antes de rodar o script."
    exit 1
fi

# Usuário real
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$REAL_USER")

echo "📦 Instalando Docker Desktop + qemu-base..."
yay -S --noconfirm --needed docker-desktop qemu-base

echo "🔧 Desabilitando serviços do Docker Desktop..."
systemctl --user disable docker-desktop.service 2>/dev/null || true
systemctl --user disable docker-desktop.socket 2>/dev/null || true
systemctl --user stop docker-desktop.service 2>/dev/null || true
systemctl --user stop docker-desktop.socket 2>/dev/null || true

# Remove systemd user leftovers
echo "🧽 Limpando services remanescentes do systemd..."
rm -f "$USER_HOME/.config/systemd/user/default.target.wants/docker-desktop.service" 2>/dev/null || true
rm -f "$USER_HOME/.config/systemd/user/default.target.wants/docker-desktop.socket" 2>/dev/null || true

# Remove Autostart completo
echo "🧹 Removendo autostart do Docker Desktop..."
rm -f "$USER_HOME/.config/autostart/docker-desktop.desktop" 2>/dev/null || true
rm -f "$USER_HOME/.config/autostart/com.docker.desktop.app.desktop" 2>/dev/null || true
rm -f "$USER_HOME/.config/autostart/*docker*.desktop" 2>/dev/null || true

# Desativa autoStart no settings.json
SETTINGS="$USER_HOME/.config/Docker Desktop/settings.json"
if [[ -f "$SETTINGS" ]]; then
    echo "⚙️ Desativando autoStart no settings.json..."
    sed -i 's/"autoStart": true/"autoStart": false/' "$SETTINGS"
fi

# Mata Chrome/Electron do Docker Desktop que inicia sozinho
echo "🛑 Finalizando processos automáticos (org.chromium)..."
pkill -f chrome 2>/dev/null || true
pkill -f org.chromium 2>/dev/null || true

# Grupo Docker
echo "👤 Adicionando '$REAL_USER' ao grupo docker..."
sudo usermod -aG docker "$REAL_USER"

echo ""
echo "✅ Docker Desktop instalado e autostart totalmente desativado!"
echo "🔁 Reinicie ou faça logout/login para ativar o grupo docker."
echo ""
echo "▶️ Para iniciar manualmente:"
echo "    systemctl --user start docker-desktop"
echo ""
echo "🐋 Para testar o Docker:"
echo "    docker run hello-world"