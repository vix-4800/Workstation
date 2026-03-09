---
prompt: |
    You are an AI assistant helping with a dotfiles repository for Arch Linux with Sway (Wayland) desktop environment.

    Follow these project-specific guidelines and conventions when working with this codebase.
---

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
workstation dotfiles status         # Check all symlinks
workstation dotfiles link -n        # Dry-run before applying
workstation dotfiles link           # Apply symlinks from dotfiles.json
workstation dotfiles doctor         # Validate environment

# Systemd commands
workstation services list           # List available services
workstation services enable-all     # Enable all services/timers
workstation services disable-all    # Disable all services/timers
workstation services status         # Show status of all services
```

**Script location**: `bin/workstation` is symlinked to `~/.local/bin/workstation` and available globally in PATH.

**Key file**: `dotfiles.json` - JSON array mapping `source` (relative to repo root) to `target` (with `$HOME` variable
support). Schema validation via `dotfiles.schema.json`.

**Adding new configs**: Edit `dotfiles.json` → run `workstation dotfiles link`. Files are symlinked, not copied. Backups
auto-created in `~/.local/share/dotfiles/backups/`.

### System Provisioning

```bash
ansible-playbook ansible/main.yml  # Full system setup
```

Playbooks are **idempotent** and **modular** - each `ansible/*.yml` handles one concern (audio, fonts, sway, etc.).
Order matters - see `ansible/main.yml` for sequence.

## Project-Specific Conventions

### Directory Structure

- `config/` - Application configs that get symlinked to `~/.config/` or `~/`
- `tools/` - Tool-specific configs (PHP linters, Python formatters, shell completions)
- `bin/` - Executable scripts (no `.sh` extensions)
- `systemd/user/` - User systemd services/timers
- `themes/` & `wallpapers/` - Visual assets (also symlinked)

### Configuration Patterns

- **Sway**: Modular in `config/sway/config.d/` with numbered prefixes (10-_, 40-_, etc.)
- **Shell**: Fish primary (`config/fish/`), Bash secondary (`config/bash/`)
- **Dev tools**: PHP/Python configs in `tools/`, completions in `config/fish/completions/`

### Systemd Services

```bash
workstation services enable batsignal.service
workstation services list
workstation services status
```

Service files in `systemd/user/` are symlinked to `~/.config/systemd/user/`.

## Code Style Guidelines

- **Idempotency**: All operations idempotent - running multiple times produces same result
- **Dry-run first**: Always use `-n` flag before applying changes
- **Modularity**: Split configs by concern using numbered prefixes (e.g., `10-vars`, `40-keys`)

### Shell Scripts (`bin/`)

- Use `#!/usr/bin/env bash` (NOT `#!/bin/sh`)
- Always use `set -euo pipefail`
- Use `local` for function variables
- Color variables: `RED`, `GRN`, `YLW`, `BLU`, `BOLD`, `DIM`, `OFF`
- Logging functions: `msg()`, `ok()`, `warn()`, `err()`

### YAML/Ansible

- Use 2-space indentation
- Prefer `community.general.pacman` for Arch packages
- Include `become: true` for privileged tasks
- Check existence before creating: `when: not stat_result.stat.exists`

### JSON Config (`dotfiles.json`)

- Use `$HOME` variable (not hardcoded paths)
- All paths relative to repo root

### Naming Conventions

- Scripts: lowercase, no extensions (e.g., `workstation`)
- Services: `*.service`, `*.timer` in `systemd/user/`
- Ansible playbooks: descriptive names (e.g., `audio.yml`, `sway.yml`)

## Build/Lint/Test Commands

```bash
# Pre-commit hooks (all linters: shellcheck, yamllint, gitleaks, etc.)
pre-commit run -a              # Run all hooks on all files
pre-commit run -a --files <file>  # Run on specific file

# Shell script linting
shellcheck bin/workstation      # Lint specific script
shellcheck bin/*                # Lint all scripts

# YAML linting (Ansible)
ansible-lint                   # Lint all playbooks
ansible-lint ansible/main.yml   # Lint specific playbook

# JSON validation
jq empty dotfiles.json          # Validate JSON syntax
jq -e '.mappings[]' dotfiles.json  # Validate structure

# Dotfiles validation
workstation dotfiles doctor     # Environment checks
workstation dotfiles status     # Check symlink status
workstation dotfiles link -n    # Dry-run symlink creation

# Ansible dry-run
ansible-playbook ansible/main.yml --check
```

## Integration Points

- **Display manager**: Greetd + ReGreet
- **Notifications**: SwayNC
- **Status bar**: Waybar
- **Lock screen**: GTKLock

## Common Gotchas

1. **Fish as default shell** - installed via Ansible, scripts should use `#!/usr/bin/env bash` not `#!/bin/sh`
2. **Wayland-specific tools** - Don't suggest X11 tools (use grim/slurp not scrot)
3. **Symlink targets** - Must use `$HOME` not hardcoded paths in `dotfiles.json`
4. **Ansible on localhost** - Uses `connection: local`, no SSH needed

## Quick Reference

- Main Ansible: `ansible/main.yml`
- Dotfiles config: `dotfiles.json`
- Sway main: `config/sway/config`
- Fish config: `config/fish/config.fish`
