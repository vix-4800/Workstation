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
just vault-encrypt      # Encrypt vault/secrets.yml (after adding secrets in plain YAML)
just vault-edit         # Edit encrypted secrets
```

## Architecture

### Single tool, single workflow

Everything is managed through **Ansible roles** — packages, configs, services, and secrets. `just` provides a thin UX
layer on top of `ansible-playbook`.

### Inventory

The checked-in inventory targets `localhost` by default. Machine-specific hardware values live in
`inventory/host_vars/localhost.yml`, which is intentionally untracked; copy the example file on each machine and adjust
`hostname`, hardware flags, and any local overrides there.

```text
inventory/
├── hosts.yml                     # Tracked inventory (defaults to localhost)
├── group_vars/all.yml            # Shared: theme, font, shell, editor...
└── host_vars/
    ├── localhost.yml.example     # Template for per-machine hardware values
    └── localhost.yml             # Local untracked copy
```

### Roles

| Role              | What it manages                                              |
| ----------------- | ------------------------------------------------------------ |
| `base`            | Locale, hostname, essential packages, env vars, fontconfig   |
| `yay`             | AUR helper installation                                      |
| `cpu`             | CPU microcode (AMD/Intel, conditional)                       |
| `gpu`             | GPU drivers + fan control (NVIDIA, conditional)              |
| `shell`           | Fish, Bash, Alacritty, Tmux, aliases                         |
| `editor`          | Neovim, VSCode flags, Git config                             |
| `audio`           | PipeWire, WirePlumber, multimedia apps                       |
| `network`         | Firewall, Bluetooth, WireGuard (vault), sing-box, VPN script |
| `desktop`         | Sway, Waybar, Wofi, SwayNC, GTKLock, Wlogout, etc.           |
| `display-manager` | Greetd + ReGreet                                             |
| `development`     | PHP, Python, Go, Docker, linter configs                      |
| `appearance`      | GTK, fonts, cursors, icons, wallpapers, themes               |
| `apps`            | Desktop applications, AUR apps, and waypaper                 |
| `services`        | All systemd user services and timers                         |
| `ai-tools`        | Codex, OpenCode, Qwen, MCP/Serena, agent skills              |

### Tags

Tasks are tagged for granular execution. The common tags are role tags (`desktop`, `network`, `development`, etc.),
type tags (`packages`, `config`, `services`, `system`), and narrower subgroup tags such as `wireguard`, `gtklock`, or
`php`.

| Tag           | Scope                                               |
| ------------- | --------------------------------------------------- |
| `config`      | Deploy user-space config files (symlinks, no sudo)  |
| `system`      | System-level configs requiring sudo (/etc/, /boot/) |
| `packages`    | Install packages                                    |
| `services`    | Manage systemd units                                |
| Role tags     | `shell`, `desktop`, `network`, etc.; some tasks use only the role tag |
| Subgroup tags | `wireguard`, `gtklock`, `php`, `docker`, etc.       |

### Secrets

WireGuard keys and VPN profiles are stored in `vault/secrets.yml`, encrypted with `ansible-vault`. Per-host variables in
`host_vars/localhost.yml` and vault variables render the final configs.

```text
vault/secrets.yml ──> host_vars/localhost.yml ──> templates/wg0.conf.j2 ──> /etc/wireguard/wg0.conf
     (encrypted)           (local vars)             (Jinja2 template)        (deployed config)
```

Create the vault file like this:

```bash
just vault-init
# create vault/secrets.yml from vault/secrets.yml.example and fill in your values
just vault-encrypt
just vault-edit
```

Before running `just vault-encrypt`, `vault/secrets.yml` may exist temporarily as plain YAML copied from the example.
After that step, `site.yml` loads it through `vars_files`, so the file must remain actual `ansible-vault` ciphertext.

If you already created `vault/secrets.yml` as plain YAML, re-encrypt it:

```bash
ansible-vault encrypt vault/secrets.yml
```

You can verify the file is encrypted if the first line starts with:

```text
$ANSIBLE_VAULT;
```

## Structure

```text
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

Host-specific state lives in the local untracked `inventory/host_vars/localhost.yml`. For example, `base` sets
`hostname`, GPU setup depends on `gpu_vendor`, battery services depend on `has_battery`, and WireGuard gets its secrets
from vault.

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

| Command              | Description                 |
| -------------------- | --------------------------- |
| `just apply`         | Full state apply            |
| `just sync`          | Deploy configs only         |
| `just plan`          | Dry-run (check mode)        |
| `just role <tags>`   | Apply specific role(s)      |
| `just bootstrap`     | First-time setup            |
| `just deps`          | Install Galaxy collections  |
| `just vault-edit`    | Edit encrypted secrets      |
| `just vault-init`    | Create vault password file  |
| `just vault-encrypt` | Encrypt `vault/secrets.yml` |
| `just services`      | Show running user services  |
| `just lint`          | Lint playbooks and roles    |
| `just check`         | Syntax check only           |
