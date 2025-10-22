# Dotfiles Repository - AI Agent Instructions

## Architecture Overview

This is a **dotfiles repository** for Arch Linux with Sway (Wayland) desktop environment. The system uses:
- **Ansible playbooks** (`ansible/*.yml`) for system provisioning and package installation
- **Unified management tool** (`bin/workstation`) for dotfiles and systemd services
- **JSON-based symlink manager** (`dotfiles.json`) for configuration file deployment
- **Catppuccin Mocha** theme consistently across all applications
- **Modular Sway config** split into `config/sway/config.d/*.conf` files by concern

## Critical Workflows

### Workstation Management (Primary Workflow)
```bash
# Dotfiles commands (available globally after first setup)
workstation status         # Check all symlinks
workstation link -n        # Dry-run before applying
workstation link           # Apply symlinks from dotfiles.json
workstation doctor         # Validate environment

# Systemd commands
workstation service list   # List available services
workstation service enable <name>  # Enable service/timer
workstation timers         # Show active timers
```

**Script location**: `bin/workstation` is symlinked to `~/.local/bin/workstation` and available globally in PATH.

**Key file**: `dotfiles.json` - JSON array mapping `source` (relative to repo root) to `target` (with `$HOME` variable support). Schema validation via `dotfiles.schema.json`.

**Adding new configs**: Edit `dotfiles.json` → run `workstation link`. Files are symlinked, not copied. Backups auto-created in `~/.local/share/dotfiles/backups/`.

### System Provisioning
```bash
ansible-playbook ansible/main.yml  # Full system setup
```

Playbooks are **idempotent** and **modular** - each `ansible/*.yml` handles one concern (audio, fonts, sway, etc.). Order matters - see `ansible/main.yml` for sequence.

## Project-Specific Conventions

### Directory Structure
- `config/` - Application configs that get symlinked to `~/.config/` or `~/`
- `tools/` - Tool-specific configs (PHP linters, Python formatters, shell completions)
- `bin/` - Executable scripts (no `.sh` extensions)
- `systemd/user/` - User systemd services/timers
- `themes/` & `wallpapers/` - Visual assets (also symlinked)

### Configuration Patterns

**Sway config** is modular:
```
config/sway/config         # Main file, includes catppuccin-mocha theme
config/sway/config.d/      # Split by concern (10-variables, 40-keybindings, etc.)
```
Number prefixes control load order. Always check `config.d/*.conf` before modifying main config.

**Shell configs** support Fish (primary) and Bash:
- Fish: `config/fish/` (with completions, functions, conf.d)
- Bash: `config/bash/` (separate .bash_profile, bashrc)

**Development tools** configs in `tools/`:
- PHP: phpstan, rector, php-cs-fixer, pint configs
- Python: flake8, mypy configs
- Completions for custom scripts in `config/fish/completions/`

### Systemd Services
Managed via `workstation service`:
```bash
workstation service enable batsignal.service
workstation service list
workstation timers
workstation timers setup
```

Service files in `systemd/user/` are symlinked to `~/.config/systemd/user/`. See `docs/SYSTEMD.md`.

## Shell Script Patterns

All `bin/` scripts follow consistent patterns:
- **Colored output**: `RED/GRN/YLW` vars for terminal colors
- **Logging functions**: `ok()`, `warn()`, `err()`, `msg()`
- **Dry-run support**: `-n` flag for safe testing
- **Relative path resolution**: Scripts find repo root via `SCRIPT_DIR`
- **Error handling**: `set -euo pipefail` for bash scripts

Example: `bin/workstation` uses `jq` for JSON parsing, `realpath` for canonicalization, and unified command interface.

## Ansible Specifics

- **Pacman/AUR packages**: Use `community.general.pacman` module
- **AUR helper**: `yay` installed via `ansible/yay.yml`
- **Become/sudo**: Most tasks need `become: true`
- **Idempotency**: Check for existence before creating (e.g., check if symlink exists)

## Theme & Visual Consistency

**Catppuccin Mocha** palette is used everywhere:
- GTK: `config/gtk/*/settings.ini`
- Terminal: `config/alacritty/catppuccin-mocha.toml`
- Sway: `config/sway/catppuccin-mocha` (color variables)
- Waybar: `config/waybar/mocha.css`
- Bat syntax: `config/bat/themes/Catppuccin Mocha.tmTheme`

When adding new tool configs, check if Catppuccin theme exists for it.

## Testing & Validation

- **Always dry-run first**: `workstation link -n`
- **Validate JSON**: `jq empty dotfiles.json`
- **Check symlinks**: `workstation status | grep "✗\|⚠"`
- **Test Ansible**: Add `--check` flag for dry-run mode

## Integration Points

- **Display manager**: Greetd + ReGreet (configured in `ansible/display-managers/greetd.yml`)
- **Notifications**: SwayNC (`config/swaync/`)
- **Status bar**: Waybar with custom scripts in `config/waybar/scripts/`
- **Lock screen**: Swaylock Effects (config in `config/swaylock/`)
- **Boot splash**: Plymouth with Catppuccin theme (`themes/plymouth/`)

## Common Gotchas

1. **Fish as default shell** - installed via Ansible, scripts should use `#!/usr/bin/env bash` not `#!/bin/sh`
2. **Wayland-specific tools** - Don't suggest X11 tools (use grim/slurp not scrot)
3. **JSON schema validation** - VS Code validates `dotfiles.json` against schema automatically
4. **Symlink targets** - Must use `$HOME` not hardcoded paths in `dotfiles.json`
5. **Ansible on localhost** - Uses `connection: local`, no SSH needed

## Quick Reference Files

- Main Ansible: `ansible/main.yml`
- Dotfiles config: `dotfiles.json`
- Sway main: `config/sway/config`
- Fish config: `config/fish/config.fish`
