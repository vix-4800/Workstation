# Ansible Playbooks - Arch Linux Setup

Automatic installation and configuration of Arch Linux with Sway.

## First Installation

```bash
sudo pacman -S ansible
ansible-galaxy collection install kewlfft.aur
cd ~/Code/Workstation
ansible-playbook ansible/main.yml --ask-become-pass
```

## Workflow Between Machines

### Changes on the First Machine
```bash
vim ~/.config/sway/config
vim ansible/optional-apps.yml

git add .
git commit -m "Update configs"
git push
```

### Apply on the Second Machine
```bash
git pull
ansible-playbook ansible/main.yml --ask-become-pass
```

## What Gets Installed

**System:**
- SwayFX, Swaylock Effects, wlogout
- Greetd + ReGreet
- Plymouth boot splash screen
- PipeWire, NetworkManager
- UFW firewall, Bluetooth
- AMD microcode, AMD/Intel GPU drivers
- Reflector

**Applications:**
- Visual Studio Code, Firefox
- Discord, Telegram, Spotify, VLC, Obsidian
- Thunar, Zathura, Feh, Wdisplays
- Catppuccin GTK theme

**CLI:**
- Fish shell (default) + Alacritty + Tmux
- Neovim
- eza, bat, ripgrep, fd, tldr, chafa

**Development:**
- Docker
- PHP + Composer (PHPStan, PHP-CS-Fixer, Rector)
- Python + pipx (Black, Flake8, MyPy)
- Go

**Dotfiles:**
- All configs managed via symlinks
- Described in `dotfiles.json`
- Automatically applied after installation

## Useful Commands

```bash
# Syntax check
ansible-playbook ansible/main.yml --syntax-check --ask-become-pass

# Dry-run
ansible-playbook ansible/main.yml --check --ask-become-pass

# Install only specific components
ansible-playbook ansible/docker.yml --ask-become-pass
ansible-playbook ansible/sway.yml --ask-become-pass
ansible-playbook ansible/dotfiles.yml --ask-become-pass
ansible-playbook ansible/development.yml --ask-become-pass
ansible-playbook ansible/optional-apps.yml --ask-become-pass
```

## Individual Playbooks

- **essential.yml** - Base packages, modern CLI tools (eza, bat, ripgrep, fd, bottom), mesa, reflector
- **cpu-microcode.yml** - CPU microcode (AMD/Intel)
- **gpu-drivers.yml** - GPU drivers (NVIDIA/AMD/Intel)
- **yay.yml** - AUR helper installation
- **dotfiles.yml** - Apply symlinks from dotfiles
- **shell.yml** - Fish shell, Alacritty, tmux, Fisher
- **editors.yml** - Neovim
- **network.yml** - NetworkManager, openssh, openssl, WireGuard
- **audio.yml** - PipeWire, WirePlumber, pavucontrol
- **fonts.yml** - JetBrains Mono Nerd Font, Font Awesome
- **sway.yml** - SwayFX, Swaylock Effects, Waybar, wofi, wlogout
- **plymouth.yml** - Plymouth boot splash screen
- **display-manager/greetd.yml** - Greetd + ReGreet display manager
- **docker.yml** - Docker and docker-compose
- **bluetooth.yml** - Bluez, bluez-utils, blueman
- **firewall.yml** - UFW firewall
- **environment.yml** - Environment variables, sudoers, wheel group
- **locale.yml** - Localization, timezone
- **multimedia.yml** - Codecs and libraries
- **development.yml** - PHP, Python, Go + dev tools
- **optional-apps.yml** - Firefox, Discord, Telegram, Spotify, VLC, Obsidian, Visual Studio Code
