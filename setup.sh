#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up ZeroTwo Desktop Environment ==="

# 1. Quickshell link
mkdir -p "$HOME/.config/quickshell"
ln -sfn "$SCRIPT_DIR" "$HOME/.config/quickshell/zerotwo"

# 2. Hyprland configuration
mkdir -p "$HOME/.config/hypr"
cp -r "$SCRIPT_DIR/dotfiles/hypr/"* "$HOME/.config/hypr/"

# 3. Fish greeting & fastfetch
mkdir -p "$HOME/.config/fish/functions" "$HOME/.config/fastfetch"
cp -r "$SCRIPT_DIR/dotfiles/fish/"* "$HOME/.config/fish/"
cp -r "$SCRIPT_DIR/dotfiles/fastfetch/"* "$HOME/.config/fastfetch/"

# 4. Wallpaper Switcher & Scripts
mkdir -p "$HOME/.local/bin" "$HOME/Pictures/wallpapers"
cp "$SCRIPT_DIR/dotfiles/scripts/wallpaper-switcher" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/wallpaper-switcher"

# 5. Shell configuration & Zero Two logo
mkdir -p "$HOME/.config/zerotwo"
cp "$SCRIPT_DIR/assets/zerotwo.png" "$HOME/.config/zerotwo/"
cp "$SCRIPT_DIR/assets/zerotwo.svg" "$HOME/.config/zerotwo/"
cat << 'SHELL_EOF' > "$HOME/.config/zerotwo/shell.json"
{
    "appearance": {
        "transparency": {
            "enabled": true
        }
    },
    "general": {
        "logo": "$HOME/.config/zerotwo/zerotwo.svg"
    }
}
SHELL_EOF
sed -i "s|\$HOME|$HOME|g" "$HOME/.config/zerotwo/shell.json"

echo "=== ZeroTwo Setup Complete! ==="
echo "Restart your shell with: zerotwo shell -d"
echo "Or run: hyprctl reload"
