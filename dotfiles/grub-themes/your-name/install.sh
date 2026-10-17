#!/usr/bin/env bash
set -e

THEME_NAME="your-name"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/boot/grub/themes/${THEME_NAME}"
USR_TARGET_DIR="/usr/share/grub/themes/${THEME_NAME}"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo: sudo ./install.sh"
    exit 1
fi

echo "=== Installing ZeroTwo '${THEME_NAME}' GRUB Theme ==="

# 1. Install theme files
mkdir -p "$TARGET_DIR" "$USR_TARGET_DIR"
cp -a "$SCRIPT_DIR"/* "$TARGET_DIR/"
cp -a "$SCRIPT_DIR"/* "$USR_TARGET_DIR/"

# 2. Configure /etc/default/grub
cp -an /etc/default/grub /etc/default/grub.bak.$(date +%s)
sed -i '/GRUB_THEME=/d' /etc/default/grub
sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="ZeroTwo Linux"/' /etc/default/grub

echo "GRUB_THEME=\"${TARGET_DIR}/theme.txt\"" >> /etc/default/grub

# 3. Update GRUB configuration
echo "Updating GRUB configuration..."
if command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif command -v update-grub >/dev/null 2>&1; then
    update-grub
fi

echo "=== GRUB Theme '${THEME_NAME}' Installed Successfully! ==="
