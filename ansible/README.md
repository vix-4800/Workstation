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

- **essential.yml** - Base packages, modern CLI tools (eza, bat, ripgrep, fd,
  tldr, chafa), reflector, pacman-contrib, udiskie, ffmpeg
- **cpu-microcode.yml** - CPU microcode (AMD/Intel)
- **gpu-drivers.yml** - GPU drivers (NVIDIA/AMD/Intel)
- **yay.yml** - AUR helper installation
- **dotfiles.yml** - Apply symlinks from dotfiles
- **shell.yml** - Fish shell, Alacritty, tmux, Fisher
- **editors.yml** - Neovim and Visual Studio Code
- **network.yml** - NetworkManager, applet/editor tools, openssh, openssl, networkmanager-dmenu-git
- **audio.yml** - PipeWire, WirePlumber, pavucontrol
- **fonts.yml** - JetBrains Mono Nerd Font, Font Awesome
- **sway.yml** - SwayFX, GTKLock, Waybar, wofi, wlogout
- **plymouth.yml** - Plymouth boot splash screen
- **display-managers/greetd.yml** - Greetd + ReGreet display manager
- **docker.yml** - Docker and docker-compose
- **bluetooth.yml** - Bluez, bluez-utils, blueman
- **firewall.yml** - UFW firewall
- **environment.yml** - Environment variables, sudoers, wheel group
- **locale.yml** - Localization, timezone
- **multimedia.yml** - Codecs and libraries
- **development.yml** - PHP, Python, Go, Composer, pipx tools, shellcheck, yamllint, markdownlint, commitlint, Postman
- **optional-apps.yml** - Firefox, Discord, Telegram, Spotify, VLC, Obsidian,
  Zathura, Thunar, GitHub CLI, WireGuard tools, OpenCode, plus AUR desktop apps

### Applications (`apps/`)

- **apps/waypaper.yml** - Waypaper wallpaper manager
