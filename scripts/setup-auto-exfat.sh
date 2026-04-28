#!/usr/bin/env bash
# setup-auto-exfat.sh
# Execute como root em Arch Linux (ex: sudo ./setup-auto-exfat.sh)

set -euo pipefail

# --- Verificação de root ---
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  Este script precisa ser executado como root."
   echo "Use: sudo $0"
   exit 1
fi
# ---------------------------

echo "1) Instalando pacotes necessários (exfatprogs, udisks2)..."
pacman --noconfirm -Syu
pacman --noconfirm -S exfatprogs udisks2

echo "2) Criando scripts de montagem / desmontagem..."

# Montagem automática
cat > /usr/local/bin/auto-exfat-mount.sh <<'EOF'
#!/usr/bin/env bash
# auto-exfat-mount.sh <DEVNODE> <UUID> <LABEL>
DEVNODE="${1:-}"
UUID="${2:-}"
LABEL="${3:-}"

if [ -z "$DEVNODE" ]; then
  echo "auto-exfat-mount: missing device" >&2
  exit 1
fi

USER_NAME=$(awk -F: '($3==1000){print $1; exit}' /etc/passwd || true)
if [ -z "$USER_NAME" ]; then
  USER_NAME=root
fi
UID_NUM=$(id -u "$USER_NAME" 2>/dev/null || echo 0)
GID_NUM=$(id -g "$USER_NAME" 2>/dev/null || echo 0)

if [ -n "$LABEL" ]; then
  MOUNT_DIR="/media/usb/${LABEL}"
elif [ -n "$UUID" ]; then
  MOUNT_DIR="/media/usb/${UUID}"
else
  devname=$(basename "$DEVNODE")
  MOUNT_DIR="/media/usb/${devname}"
fi

mkdir -p "$MOUNT_DIR"
chown root:root "$MOUNT_DIR"
chmod 0777 "$MOUNT_DIR"

sleep 0.5

mountpoint -q "$MOUNT_DIR" && exit 0

echo "Montando $DEVNODE em $MOUNT_DIR (opções: rw,sync,noatime,uid=${UID_NUM},gid=${GID_NUM})"
mount -o rw,sync,noatime,uid="$UID_NUM",gid="$GID_NUM" "$DEVNODE" "$MOUNT_DIR" || exit 1

sync

echo "mounted-by-auto-exfat-mount.sh $(date -Is) on $DEVNODE" > "$MOUNT_DIR/.mounted_by_auto_exfat"
chown "$UID_NUM:$GID_NUM" "$MOUNT_DIR/.mounted_by_auto_exfat" || true

exit 0
EOF

chmod +x /usr/local/bin/auto-exfat-mount.sh

# Desmontagem automática
cat > /usr/local/bin/auto-exfat-umount.sh <<'EOF'
#!/usr/bin/env bash
DEVNODE="${1:-}"
if [ -z "$DEVNODE" ]; then exit 1; fi

mountpoint=$(grep -E "^${DEVNODE}[[:space:]]" /proc/mounts | awk '{print $2}' | head -n1)

if [ -n "$mountpoint" ]; then
  sync
  umount "$mountpoint" || umount -l "$mountpoint" || true
fi
exit 0
EOF

chmod +x /usr/local/bin/auto-exfat-umount.sh

echo "3) Criando regras udev..."
cat > /etc/udev/rules.d/99-auto-exfat.rules <<'EOF'
ACTION=="add", ENV{ID_FS_TYPE}=="exfat", RUN+="/usr/bin/systemd-run --no-block /usr/local/bin/auto-exfat-mount.sh %E{DEVNAME} %E{ID_FS_UUID} %E{ID_FS_LABEL}"
ACTION=="remove", ENV{ID_FS_TYPE}=="exfat", RUN+="/usr/bin/systemd-run --no-block /usr/local/bin/auto-exfat-umount.sh %E{DEVNAME}"
EOF

echo "4) Recarregando udev..."
udevadm control --reload-rules
udevadm trigger --action=add

echo "Feito."
