# Ansible Playbooks - Arch Linux Setup

Automatic installation and configuration of Arch Linux with Sway.

## First Installation

```bash
sudo pacman -S ansible
ansible-galaxy collection install kewlfft.aur
cd ~/Code/Workstation
ansible-playbook ansible/main.yml
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
ansible-playbook ansible/main.yml
```

## What Gets Installed

**System:**
- SwayFX, Swaylock Effects, wlogout
- Greetd + ReGreet
- PipeWire, NetworkManager
- UFW firewall, Bluetooth
- AMD microcode, AMD/Intel GPU drivers

**Applications:**
- VS Code, Firefox
- Discord, Telegram, Spotify, VLC, Obsidian
- Thunar, Zathura, Feh, Wdisplays
- Catppuccin GTK theme

**CLI:**
- Fish shell (default) + Alacritty + Tmux
- Neovim + micro
- eza, bat, ripgrep, fd, tldr, neofetch

**Development:**
- Docker
- PHP + Composer (PHPStan, PHP-CS-Fixer, Rector)
- Python + pipx (Black, Flake8, MyPy)
- Go

**Dotfiles:**
- All configs managed via symlinks
- Described in `linux.confmap`
- Automatically applied after installation

## Useful Commands

```bash
# Syntax check
ansible-playbook ansible/main.yml --syntax-check

# Dry-run
ansible-playbook ansible/main.yml --check

# Install only specific components
ansible-playbook ansible/docker.yml
ansible-playbook ansible/sway.yml
ansible-playbook ansible/dotfiles.yml
```
