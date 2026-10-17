#!/usr/bin/env bash
set -e

echo "=== ZeroTwo OS Application Installer ==="
echo "Installing requested applications and AMD graphics packages..."
echo ""

# Core requested apps
sudo pacman -S --needed --noconfirm \
    helvum \
    telegram-desktop

# AMD Radeon Graphics & Hardware Acceleration (Rembrandt iGPU + Navi dGPU)
sudo pacman -S --needed --noconfirm \
    mesa \
    vulkan-radeon \
    libva-mesa-driver \
    vulkan-tools

# Link zerotwo command globally
sudo ln -sf "$HOME/.local/bin/zerotwo" /usr/local/bin/zerotwo

echo ""
echo "=== Installation Completed Successfully! ==="
echo "You can now use:"
echo "  - Super + H: Launch Helvum"
echo "  - Alt + T: Launch Telegram Desktop"
echo "  - zerotwo shell -d: Launch / reload desktop shell"
