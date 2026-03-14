# Workstation

Machine state management for Arch Linux with Sway (Wayland) desktop environment.

Ansible-driven provisioning and configuration for multiple workstations from a single repository.

## Quick Start

### Bootstrap from scratch

```bash
sudo pacman -S --needed git ansible just
git clone https://github.com/vix-4800/Workstation ~/Code/Workstation
cd ~/Code/Workstation
just bootstrap
```

### Daily usage

```bash
just apply              # Full state: packages + configs + services
just sync               # Only configs (fast, no package installs)
just plan               # Dry-run: show what would change
just role shell         # Apply specific role
just role desktop network   # Multiple roles
```

### Secrets

```bash
just vault-init         # Create vault password file (first time)
just vault-create       # Create encrypted vault/secrets.yml from the example
just vault-edit         # Edit encrypted secrets
```

## Architecture

### Single tool, single workflow

Everything is managed through **Ansible roles** — packages, configs, services, and secrets.
`just` provides a thin UX layer on top of `ansible-playbook`.

### Multi-machine support

Machines are defined in `inventory/hosts.yml` with per-host variables in `host_vars/`.
Ansible auto-detects the current machine by hostname and applies the correct configuration.

```
inventory/
├── hosts.yml                     # Machine definitions
├── group_vars/all.yml            # Shared: theme, font, shell, editor...
└── host_vars/
    ├── saga.yml                  # Laptop: AMD, no GPU, battery
    └── desktop.yml               # Desktop: Intel, NVIDIA, no battery
```

### Roles

| Role | What it manages |
|------|----------------|
| `base` | Locale, hostname, essential packages, env vars, fontconfig |
| `yay` | AUR helper installation |
| `cpu` | CPU microcode (AMD/Intel, conditional) |
| `gpu` | GPU drivers + fan control (NVIDIA, conditional) |
| `shell` | Fish, Bash, Alacritty, Tmux, aliases |
| `editor` | Neovim, VSCode flags, Git config |
| `audio` | PipeWire, WirePlumber, multimedia apps |
| `network` | Firewall, Bluetooth, WireGuard (vault), sing-box, VPN script |
| `desktop` | Sway, Waybar, Wofi, SwayNC, GTKLock, Wlogout, etc. |
| `display-manager` | Greetd + ReGreet |
| `development` | PHP, Python, Go, Docker, linter configs |
| `appearance` | GTK, fonts, cursors, icons, wallpapers, themes |
| `services` | All systemd user services and timers |
| `ai-tools` | Codex, OpenCode, Qwen, MCP/Serena, agent skills |

### Tags

Every task is tagged for granular execution:

| Tag | Scope |
|-----|-------|
| `config` | Deploy user-space config files (symlinks, no sudo) |
| `system` | System-level configs requiring sudo (/etc/, /boot/) |
| `packages` | Install packages |
| `services` | Manage systemd units |
| Per-role tags | `shell`, `desktop`, `network`, etc. |

### Secrets

WireGuard keys and VPN profiles are stored in `vault/secrets.yml`, encrypted with `ansible-vault`.
Per-host variables in `host_vars/` reference vault secrets, and templates render the final configs.

```
vault/secrets.yml ──> host_vars/saga.yml ──> templates/wg0.conf.j2 ──> /etc/wireguard/wg0.conf
     (encrypted)        (per-host vars)         (Jinja2 template)        (deployed config)
```

Create the vault file like this:

```bash
just vault-init
just vault-create
just vault-edit
```

Do not create `vault/secrets.yml` with a plain `cp` or editor save. `site.yml` loads it through `vars_files`, so the file must be actual `ansible-vault` ciphertext.

If you already created `vault/secrets.yml` as plain YAML, re-encrypt it:

```bash
ansible-vault encrypt vault/secrets.yml
```

You can verify the file is encrypted if the first line starts with:

```text
$ANSIBLE_VAULT;
```

## Structure

```
├── Justfile                    # Command interface
├── ansible.cfg                 # Ansible settings
├── requirements.yml            # Galaxy collections
├── site.yml                    # Master playbook
├── inventory/                  # Machine definitions + variables
├── vault/                      # Encrypted secrets
└── roles/
    └── <role>/
        ├── tasks/main.yml      # What to install and deploy
        ├── defaults/main.yml   # Default variables
        ├── files/              # Config files (symlinked to ~/)
        ├── templates/          # Jinja2 templates
        ├── handlers/main.yml   # Event handlers (daemon-reload, etc.)
        └── scripts/            # Executable scripts (→ ~/.local/bin/)
```

## Workflow

### Changed a config on machine A

```bash
# On machine A: edit the file (it's a symlink into the repo)
vim roles/desktop/files/waybar/style.css
git add -A && git commit -m "feat: update waybar style" && git push

# On machine B:
git pull && just sync
```

### Adding a new package

Add it to the appropriate role's `tasks/main.yml`, commit, push, and run `just apply` on both machines.

### Host-specific behavior

GPU role skips on laptop (`gpu_vendor: none`), batsignal skips on desktop (`has_battery: false`),
WireGuard gets the correct key from vault via `host_vars`.

## Desktop Stack

- **SwayFX** — compositor (blur, shadows, rounded corners)
- **Waybar** — status bar with custom scripts
- **Greetd + ReGreet** — display manager
- **GTKLock** — screen locker
- **SwayNC** — notifications
- **Wofi** — launcher
- **Catppuccin Mocha** — consistent theme everywhere

## Prerequisites

- Arch Linux
- `sudo` access
- Internet connection

## Just Commands

| Command | Description |
|---------|-------------|
| `just apply` | Full state apply |
| `just sync` | Deploy configs only |
| `just plan` | Dry-run (check mode) |
| `just role <tags>` | Apply specific role(s) |
| `just bootstrap` | First-time setup |
| `just deps` | Install Galaxy collections |
| `just vault-edit` | Edit encrypted secrets |
| `just vault-init` | Create vault password file |
| `just vault-create` | Create encrypted `vault/secrets.yml` from the example |
| `just services` | Show running user services |
| `just lint` | Lint playbooks and roles |
| `just check` | Syntax check only |
