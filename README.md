# Dotfiles

Personal configuration files for Linux desktop environment with Sway (Wayland) and development tools.

## Quick Start

### Arch Linux Auto Setup

For a fresh Arch Linux installation:

```bash
curl -fsSL https://raw.githubusercontent.com/vix-4800/dotfiles/main/bin/arch-setup | bash
```

See [ARCH_SETUP.md](ARCH_SETUP.md) for detailed information.

### Manual Installation

```bash
git clone https://github.com/vix-4800/dotfiles.git ~/Code/Dotfiles
cd ~/Code/Dotfiles
./bin/dotfiles link
```

## What's Included

- **Sway** - Wayland compositor configuration
- **Waybar** - Status bar configuration
- **Wofi** - Application launcher
- **Mako** - Notification daemon
- **Alacritty** - Terminal emulator
- **Neovim** - Editor configuration with plugins
- **Fish** - Shell configuration and functions
- **Git** - Git configuration and aliases
- **Development tools** - PHP, Python, JavaScript toolchain configs

## Scripts

- `bin/arch-setup` - Complete Arch Linux system setup
- `bin/dotfiles` - Dotfiles management (link/unlink)
- `bin/screenshot` - Screenshot utility

## Package Management

Package lists are defined in `packages.json`:

- **pacman** - Arch Linux packages
- **AUR** - Arch User Repository packages
- **pipx** - Python tools
- **composer** - PHP packages
- **npm** - Node.js packages

## Usage

### Link dotfiles

```bash
./bin/dotfiles link
```

### Take screenshot

```bash
./bin/screenshot
```
