#!/bin/bash
# ============================================================
# 🐳 Instalação automatizada do Docker Desktop no Arch Linux
# ------------------------------------------------------------
# Esta versão:
# - Instala Docker Desktop via AUR
# - Remove TODOS os mecanismos de autostart (systemd, DBus, Electron, Portal)
# - Impede totalmente o auto-launch do org.chromium.chrome
# - Ajusta settings.json
# - Adiciona usuário ao grupo docker
# ============================================================

set -e

echo "🚀 Instalando Docker Desktop no Arch Linux..."

# Verifica bash
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# Verifica yay
if ! command -v yay &>/dev/null; then
    echo "❌ 'yay' não encontrado. Instale antes!"
    exit 1
fi

# Define usuário real
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$REAL_USER")

echo "📦 Instalando Docker Desktop..."
yay -S --noconfirm --needed docker-desktop qemu-base

# ------------------------------------------------------------
# 1) Desativa systemd user
# ------------------------------------------------------------
echo "🔧 Desabilitando systemd user services..."
systemctl --user disable docker-desktop.service 2>/dev/null || true
systemctl --user disable docker-desktop.socket 2>/dev/null || true
systemctl --user stop docker-desktop.service 2>/dev/null || true
systemctl --user stop docker-desktop.socket 2>/dev/null || true

rm -f "$USER_HOME/.config/systemd/user/docker-desktop.service"
rm -f "$USER_HOME/.config/systemd/user/docker-desktop.socket"
rm -f "$USER_HOME/.config/systemd/user/default.target.wants/docker-desktop.service"
rm -f "$USER_HOME/.config/systemd/user/default.target.wants/docker-desktop.socket"

# ------------------------------------------------------------
# 2) Remove todos os autostarts
# ------------------------------------------------------------
echo "🧹 Removendo autostart (Electron / Docker Desktop)..."
rm -f "$USER_HOME/.config/autostart/"*docker* 2>/dev/null || true
rm -f "$USER_HOME/.config/autostart/"*Docker* 2>/dev/null || true
rm -f "$USER_HOME/.config/autostart/"*chrome* 2>/dev/null || true
rm -f "$USER_HOME/.config/autostart/"*electron* 2>/dev/null || true

# ------------------------------------------------------------
# 3) Remove DBus services que fazem ele iniciar sozinho
# ------------------------------------------------------------
echo "🛑 Removendo DBus auto-launch..."
rm -f "$USER_HOME/.local/share/dbus-1/services/com.docker.service" 2>/dev/null || true
rm -f "$USER_HOME/.local/share/dbus-1/services/"*docker* 2>/dev/null || true
rm -f "$USER_HOME/.local/share/dbus-1/services/"*Docker* 2>/dev/null || true

# ------------------------------------------------------------
# 4) Remove xdg-desktop-portal entries
# ------------------------------------------------------------
echo "🧨 Removendo xdg-desktop-portal entry..."
sudo rm -f /usr/share/xdg-desktop-portal/applications/docker-desktop.desktop 2>/dev/null || true

# ------------------------------------------------------------
# 5) settings.json → autoStart false
# ------------------------------------------------------------
SETTINGS="$USER_HOME/.config/Docker Desktop/settings.json"
if [[ -f "$SETTINGS" ]]; then
    echo "⚙ Corrigindo settings.json (autoStart false)..."
    sed -i 's/"autoStart": true/"autoStart": false/g' "$SETTINGS"
fi

# ------------------------------------------------------------
# 6) Mata processos chromium/electron iniciados automaticamente
# ------------------------------------------------------------
echo "🛑 Matando processos autoiniciados..."
pkill -f chrome 2>/dev/null || true
pkill -f electron 2>/dev/null || true
pkill -f Docker 2>/dev/null || true
pkill -f org.chromium 2>/dev/null || true

# ------------------------------------------------------------
# 7) Ajusta permissões para impedir reativação automática
# ------------------------------------------------------------
echo "⛔ Bloqueando binários de autostart automático..."
find "$USER_HOME/.docker-desktop/app" -type f -name "chrome*" -exec chmod 000 {} \; 2>/dev/null || true
find "$USER_HOME/.docker-desktop/app" -type f -name "chrome_crashpad_handler" -exec chmod 000 {} \; 2>/dev/null || true

# ------------------------------------------------------------
# 8) Grupo docker
# ------------------------------------------------------------
echo "👤 Adicionando '$REAL_USER' ao grupo docker..."
sudo usermod -aG docker "$REAL_USER"

echo ""
echo "✅ Docker Desktop instalado SEM autostart."
echo "▶️ Para iniciar manualmente:"
echo "    systemctl --user start docker-desktop"
echo ""
echo "🐋 Para testar:"
echo "    docker run hello-world"