---
prompt: |
    You are an AI assistant helping with a workstation state management repository for Arch Linux with Sway (Wayland).
    This repo uses Ansible roles to provision and configure multiple machines from a single source of truth.
    Follow these project-specific guidelines and conventions when working with this codebase.
---

# Workstation Repository - AI Agent Instructions

## Architecture Overview

This is a **machine state management repository** for Arch Linux with Sway (Wayland) desktop environment.

- **Ansible roles** (`roles/`) — single tool for packages, configs, services, and secrets
- **Inventory** (`inventory/`) — multi-machine support via `host_vars/`
- **Justfile** — UX layer for common commands (`just apply`, `just sync`, `just plan`)
- **ansible-vault** (`vault/`) — encrypted secrets (WireGuard keys, VPN profiles)
- **Catppuccin Mocha** theme consistently across all applications
- **Modular Sway config** split into `roles/desktop/files/sway/config.d/*.conf`

## Critical Workflows

### Apply full state

```bash
just apply              # Packages + configs + services (auto-detects host)
just sync               # Only configs (fast)
just plan               # Dry-run
just role shell         # Specific role
just role desktop network   # Multiple roles
```

### Secrets management

```bash
just vault-init         # Create .vault-password (first time)
just vault-edit         # Edit encrypted secrets
```

### Bootstrap from scratch

```bash
sudo pacman -S --needed git ansible just
git clone <repo> ~/Code/Workstation && cd ~/Code/Workstation
just bootstrap
```

## Project Structure

```
├── Justfile                    # Command interface (replaces bin/workstation)
├── ansible.cfg                 # Ansible settings (inventory, vault, roles_path)
├── requirements.yml            # Ansible Galaxy collections
├── site.yml                    # Master playbook (imports all roles with tags)
├── inventory/
│   ├── hosts.yml               # Machine definitions
│   ├── group_vars/all.yml      # Shared variables (theme, font, shell, editor)
│   └── host_vars/
│       ├── saga.yml            # Laptop: AMD CPU, no GPU, has battery
│       └── <desktop>.yml       # Desktop: Intel CPU, NVIDIA, no battery
├── vault/
│   ├── secrets.yml             # Encrypted (gitignored)
│   └── secrets.yml.example     # Template for secrets
└── roles/
    └── <role>/
        ├── tasks/main.yml      # Installation and deployment tasks
        ├── defaults/main.yml   # Default variables (overridable per-host)
        ├── files/              # Config files (symlinked to target paths)
        ├── templates/          # Jinja2 templates (rendered from vault/host vars)
        ├── handlers/main.yml   # Event handlers (daemon-reload, etc.)
        └── scripts/            # Executable scripts (→ ~/.local/bin/)
```

### Roles

| Role | Concern |
|------|---------|
| `base` | Locale, hostname, essential packages, env vars, fontconfig |
| `yay` | AUR helper installation |
| `cpu` | CPU microcode (conditional: `cpu_vendor`) |
| `gpu` | GPU drivers + fan control (conditional: `gpu_vendor`) |
| `shell` | Fish, Bash, Alacritty, Tmux, aliases |
| `editor` | Neovim, VSCode flags, Git config |
| `audio` | PipeWire, WirePlumber, multimedia |
| `network` | Firewall, Bluetooth, WireGuard, sing-box, VPN script |
| `desktop` | Sway, Waybar, Wofi, SwayNC, GTKLock, Wlogout, etc. |
| `display-manager` | Greetd + ReGreet |
| `development` | PHP, Python, Go, Docker, all linter configs |
| `appearance` | GTK, fonts, cursors, icons, wallpapers, themes |
| `services` | All systemd user services and timers |
| `ai-tools` | Codex, OpenCode, Qwen, MCP/Serena, agent skills |

## Code Style Guidelines

### Ansible Tasks

- Use 2-space indentation
- Every task must have tags: `[<role>, <type>]` where type is `packages`, `config`, or `services`
- Prefer `community.general.pacman` for Arch packages, `kewlfft.aur.aur` for AUR
- Use `become: true` only where needed (package install, system paths)
- Config deployment: `ansible.builtin.file` with `state: link` (symlinks, not copies)
- Templates for secrets: `ansible.builtin.template` with vault variables
- Use variables from `defaults/main.yml`, not hardcoded values
- Include subtasks via `ansible.builtin.include_tasks` for complex roles

### Shell Scripts (`roles/*/scripts/`)

- Use `#!/usr/bin/env bash` (NOT `#!/bin/sh`)
- Always use `set -euo pipefail`
- Use `local` for function variables
- No `.sh` extensions

### Variables

- `dotfiles_dir` — absolute path to repo root (`{{ playbook_dir }}`)
- `username` — system username
- `hostname` — machine hostname (from `host_vars`)
- `cpu_vendor` / `gpu_vendor` — for conditional hardware roles
- `has_battery` — for conditional service enablement
- Vault secrets prefixed with `vault_` (e.g., `vault_wg_private_key_saga`)

### Naming Conventions

- Roles: lowercase with hyphens (e.g., `display-manager`, `ai-tools`)
- Tasks: descriptive names starting with verb (e.g., "Install", "Deploy", "Enable")
- Variables: snake_case
- Files in `files/`: mirror the target structure (e.g., `files/sway/config.d/`)

## Build/Lint/Test Commands

```bash
just lint               # ansible-lint on all roles
just check              # Syntax check only
just plan               # Dry-run (--check --diff)
pre-commit run -a       # All pre-commit hooks
shellcheck roles/*/scripts/*   # Lint scripts
```

## Adding New Configuration

1. Identify the appropriate role (or create a new one in `roles/`)
2. Place config files in `roles/<role>/files/`
3. Add a symlink task in `roles/<role>/tasks/main.yml`:

   ```yaml
   - name: Deploy <config> config
     ansible.builtin.file:
       src: "{{ dotfiles_dir }}/roles/<role>/files/<config>"
       dest: "{{ ansible_env.HOME }}/.config/<config>"
       state: link
       force: true
     tags: [<role>, config]
   ```

4. If it needs per-host values, use a template in `roles/<role>/templates/`
5. Commit, push, and run `just sync` on both machines

## Adding a New Machine

1. Add host to `inventory/hosts.yml`
2. Create `inventory/host_vars/<hostname>.yml` with machine-specific vars
3. Add vault secrets for the new host in `vault/secrets.yml`
4. On the new machine: `just bootstrap`

## Common Gotchas

1. **Fish shell** — scripts use `#!/usr/bin/env bash`, not Fish syntax
2. **Wayland only** — use grim/slurp (not scrot), wl-clipboard (not xclip)
3. **Symlink direction** — `src` is inside the repo, `dest` is the target in `~/`
4. **Vault required** — `vault/secrets.yml` must exist (even if empty) for `site.yml` to parse
5. **Host detection** — `just` reads `/etc/hostname` to select the right `host_vars`
6. **`become: false`** — needed for AUR packages (yay runs as user)

## Quick Reference

- Master playbook: `site.yml`
- Ansible config: `ansible.cfg`
- Sway config: `roles/desktop/files/sway/config`
- Fish config: `roles/shell/files/fish/config.fish`
- Waybar config: `roles/desktop/files/waybar/config.jsonc`
- Vault secrets: `just vault-edit`
