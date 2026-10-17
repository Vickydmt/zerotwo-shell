<h1 align="center">ZeroTwo Shell & Dotfiles</h1>

<p align="center">
  <b>Personalized ZeroTwo Desktop Environment for ASUS ROG Zephyrus G14 (AMD Ryzen + Radeon)</b><br>
  Built with Quickshell, Hyprland (Lua), Fish, and Fastfetch
</p>

---

## Features

- **Branding**: Custom Zero Two (`02`) logo with iconic red horns and sakura aesthetic.
- **Hardware Optimized**: Fully configured for ASUS ROG Zephyrus G14 (Rembrandt AMD Ryzen 6800H iGPU + Navi AMD Radeon RX 6700S/6800S dGPU).
- **Dual Display**: Automatic multi-screen support (`eDP-2` 144Hz + external `HDMI-A-1` / DisplayPort).
- **Dynamic Wallpaper Switcher**:
  - `Super + Up`: Next wallpaper (`~/Pictures/wallpapers`)
  - `Super + Down`: Previous wallpaper (`~/Pictures/wallpapers`)
  - Automatic Material You color scheme adaptation on change.
- **Fish & Fastfetch**: Custom Zero Two ASCII greeting on new terminals.

## Keybindings

| Keybinding | Action |
| --- | --- |
| `Super + Return` | Open Fish Terminal (`foot`) |
| `Alt + F` | Open Firefox |
| `Super + T` | Open File Manager (`thunar`) |
| `Super + H` | Open Helvum (Audio Routing) |
| `Alt + T` | Open Telegram Desktop |
| `Super + D` | Application Launcher Menu |
| `Super + Up` | Next Wallpaper + Adapt Colors |
| `Super + Down` | Previous Wallpaper + Adapt Colors |

## Setup & Restoration

To restore or install on a fresh system:

```bash
git clone <your-repo-url> ~/shell
cd ~/shell
./setup.sh
```

To install missing applications and graphics drivers:

```bash
~/install-apps.sh
```

## Pushing to your own Git Repository

To upload this repository to your own GitHub account:

```bash
# 1. Update remote URL to your repository
git remote set-url origin https://github.com/<your-username>/<your-repo-name>.git

# 2. Stage all changes
git add .

# 3. Commit
git commit -m "feat: complete ZeroTwo OS rebrand and G14 AMD configuration"

# 4. Push to your repo
git push -u origin main
```
