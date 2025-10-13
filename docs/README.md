# Dotfiles

Personal configuration files for Linux desktop environment with Sway (Wayland) and development
tools.

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
- **SwayNC** - Sway notification manager
- **Alacritty** - Terminal emulator
- **Neovim** - Editor configuration with plugins
- **Fish** - Shell configuration and functions
- **Git** - Git configuration and aliases
- **Development tools** - PHP, Python, JavaScript toolchain configs
- **Shell Configuration** - Centralized configuration for bash, zsh, and fish (see
  [SHELL_CONFIG.md](SHELL_CONFIG.md))
- **Modern Config Management** - YAML-based configuration system (see
  [CONFIG_MANAGEMENT.md](CONFIG_MANAGEMENT.md))

## Scripts

- `bin/arch-setup` - Complete Arch Linux system setup
- `bin/dotfiles` - Dotfiles management (link/unlink)
- `bin/config` - Configuration management helper (YAML ↔ confmap)
- `bin/test-shell-config` - Shell configuration testing

## Usage

### Link dotfiles

```bash
./bin/dotfiles link
```
