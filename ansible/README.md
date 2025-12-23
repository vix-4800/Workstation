# Ansible Playbooks - Arch Linux Setup

Automatic installation and configuration of Arch Linux with Sway.

## First Installation

```bash
sudo pacman -S ansible
ansible-galaxy collection install kewlfft.aur
cd <path_to_this_repo>
ansible-playbook ansible/main.yml --ask-become-pass
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
- **display-managers/greetd.yml** - Greetd + ReGreet display manager
- **docker.yml** - Docker and docker-compose
- **bluetooth.yml** - Bluez, bluez-utils, blueman
- **firewall.yml** - UFW firewall
- **environment.yml** - Environment variables, sudoers, wheel group
- **locale.yml** - Localization, timezone
- **multimedia.yml** - Codecs and libraries
- **development.yml** - PHP, Python, Go + dev tools
- **optional-apps.yml** - Brave, Discord, Telegram, Spotify, VLC, Obsidian, Visual Studio Code

### Applications (`apps/`)

- **apps/spicetify.yml** - Spicetify CLI, Marketplace, and Spotify permissions
- **apps/waypaper.yml** - Waypaper wallpaper manager
