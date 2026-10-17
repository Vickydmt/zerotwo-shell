#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script configures system files and GRUB."
    echo "Please run with sudo: sudo ~/apply-zerotwo-os.sh"
    exit 1
fi

echo "========================================="
echo "   Applying ZeroTwo Linux System Setup   "
echo "========================================="
echo ""

# ------------------------------------------------------------------
# 1. System OS Rebranding -> ZeroTwo Linux
# ------------------------------------------------------------------
echo "[1/4] Rebranding OS name to ZeroTwo Linux..."

# Backup original os-release if not already backed up
if [ ! -f /etc/os-release.arch.bak ]; then
    cp -L /etc/os-release /etc/os-release.arch.bak 2>/dev/null || true
fi

# Write new /etc/os-release
cat << 'OS_EOF' > /etc/os-release
NAME="ZeroTwo Linux"
PRETTY_NAME="ZeroTwo Linux"
ID=zerotwo
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;255;110;140"
HOME_URL="https://github.com/zerotwo"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
LOGO=zerotwo
OS_EOF

# Update /usr/lib/os-release as well
cp -f /etc/os-release /usr/lib/os-release 2>/dev/null || true

# Update /etc/lsb-release
cat << 'LSB_EOF' > /etc/lsb-release
DISTRIB_ID=ZeroTwo
DISTRIB_RELEASE=rolling
DISTRIB_DESCRIPTION="ZeroTwo Linux"
LSB_EOF

# Update /etc/issue and /etc/issue.net
echo 'ZeroTwo Linux \r (\l)' > /etc/issue
echo 'ZeroTwo Linux %r (%l)' > /etc/issue.net

echo "  -> OS identification updated to ZeroTwo Linux."

# ------------------------------------------------------------------
# 2. Install 'your-name' GRUB Theme
# ------------------------------------------------------------------
echo "[2/4] Installing 'your-name' GRUB Theme..."

THEME_SRC="/home/zerotwo/GRUB-Theme/your-name"
THEME_DEST="/boot/grub/themes/your-name"
USR_THEME_DEST="/usr/share/grub/themes/your-name"

mkdir -p "$THEME_DEST" "$USR_THEME_DEST"
cp -a "$THEME_SRC"/* "$THEME_DEST/"
cp -a "$THEME_SRC"/* "$USR_THEME_DEST/"

echo "  -> Copied theme files to $THEME_DEST."

# ------------------------------------------------------------------
# 3. Configure /etc/default/grub
# ------------------------------------------------------------------
echo "[3/4] Configuring /etc/default/grub..."

# Backup grub default config
cp -an /etc/default/grub /etc/default/grub.bak.$(date +%s)

# Set GRUB_DISTRIBUTOR and GRUB_THEME
sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="ZeroTwo Linux"/' /etc/default/grub
sed -i '/GRUB_THEME=/d' /etc/default/grub
echo 'GRUB_THEME="/boot/grub/themes/your-name/theme.txt"' >> /etc/default/grub

# ------------------------------------------------------------------
# 4. Update GRUB Bootloader
# ------------------------------------------------------------------
echo "[4/4] Generating new grub.cfg with grub-mkconfig..."

if command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif command -v update-grub >/dev/null 2>&1; then
    update-grub
fi

# Link zerotwo binary system-wide
if [ -f "/home/zerotwo/.local/bin/zerotwo" ]; then
    ln -sf "/home/zerotwo/.local/bin/zerotwo" /usr/local/bin/zerotwo
fi

echo ""
echo "========================================="
echo "   ZeroTwo Linux Setup Applied Cleanly!  "
echo "========================================="
echo "Changes active:"
echo "  - OS Name: ZeroTwo Linux"
echo "  - GRUB Theme: your-name (with ZeroTwo logo & your-name wallpaper)"
echo "  - Boot Entries: ZeroTwo Linux"
echo "  - Global CLI: zerotwo"
