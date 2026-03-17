# Workstation

Machine state management for Arch Linux with Sway (Wayland) desktop environment.

Ansible-driven provisioning and configuration for multiple workstations from a single repository.

## Quick Start

### First run on a fresh system

```bash
sudo pacman -Syu --needed sudo vim git ansible just base-devel
git clone https://github.com/vix-4800/Workstation ~/Code/Workstation
cd ~/Code/Workstation
cp inventory/host_vars/localhost.yml.example inventory/host_vars/localhost.yml
cp vault/secrets.yml.example vault/secrets.yml
just vault-init
# edit inventory/host_vars/localhost.yml and vault/secrets.yml
just vault-encrypt
just deps
just apply
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

## Fresh System Setup

Use this order on a clean Arch install. `just apply` is not enough by itself on a fresh machine.

### 1. Prepare the user and sudo

The target user must exist before running this repo and must be allowed to use `sudo`, because `just apply` runs
`ansible-playbook --ask-become-pass`.

Example:

```bash
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
EDITOR=vim visudo
```

Enable sudo for the `wheel` group in `/etc/sudoers`:

```text
%wheel ALL=(ALL:ALL) ALL
```

Then log in as that user.

### 2. Install required packages

Install the base tools that are needed before this repository can manage the rest of the system:

```bash
sudo pacman -Syu --needed sudo vim git ansible just base-devel
```

These are needed for:

- `sudo` — privilege escalation for Ansible tasks
- `vim` — editing `host_vars`, vault files, and `visudo`
- `git` — cloning and updating the repository
- `ansible` — running the playbook
- `just` — command runner used by this repo
- `base-devel` — required for AUR builds during `yay`/AUR tasks

### 3. Clone the repository

```bash
git clone https://github.com/vix-4800/Workstation ~/Code/Workstation
cd ~/Code/Workstation
```

### 4. Create host variables

This file is intentionally untracked and must be created locally on every machine:

```bash
cp inventory/host_vars/localhost.yml.example inventory/host_vars/localhost.yml
vim inventory/host_vars/localhost.yml
```

At minimum, fill in the machine-specific values such as:

- `username`
- `hostname`
- `cpu_vendor`
- `gpu_vendor`
- `has_battery`

### 5. Create vault secrets

`site.yml` always loads `vault/secrets.yml`, so the file must exist before you run the playbook.

```bash
cp vault/secrets.yml.example vault/secrets.yml
vim vault/secrets.yml
just vault-init
just vault-encrypt
```

After encryption, the file must start with `$ANSIBLE_VAULT;`.

### 6. Install Ansible collections

This repository depends on Galaxy collections declared in [requirements.yml](/home/vix/Code/Workstation/requirements.yml),
including `kewlfft.aur`. On a clean system install them before the first apply:

```bash
just deps
```

Equivalent command:

```bash
ansible-galaxy collection install -r requirements.yml
```

### 7. Run the first apply

```bash
just apply
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
| `ai-tools`        | Codex, Qwen, MCP/Serena, agent skills              |

### Tags

Tasks are tagged for granular execution. The common tags are role tags (`desktop`, `network`, `development`, etc.), type
tags (`packages`, `config`, `services`, `system`), and narrower subgroup tags such as `wireguard`, `gtklock`, or `php`.

| Tag           | Scope                                                                 |
| ------------- | --------------------------------------------------------------------- |
| `config`      | Deploy user-space config files (symlinks, no sudo)                    |
| `system`      | System-level configs requiring sudo (/etc/, /boot/)                   |
| `packages`    | Install packages                                                      |
| `services`    | Manage systemd units                                                  |
| Role tags     | `shell`, `desktop`, `network`, etc.; some tasks use only the role tag |
| Subgroup tags | `wireguard`, `gtklock`, `php`, `docker`, etc.                         |

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
- A local user account already created
- The user is in `wheel` (or otherwise configured in `sudoers`)
- `sudo`, `vim`, `git`, `ansible`, `just`, and `base-devel` installed
- Internet connection

## Just Commands

| Command              | Description                 |
| -------------------- | --------------------------- |
| `just apply`         | Full state apply            |
| `just sync`          | Deploy configs only         |
| `just plan`          | Dry-run (check mode)        |
| `just role <tags>`   | Apply specific role(s)      |
| `just deps`          | Install Galaxy collections  |
| `just vault-edit`    | Edit encrypted secrets      |
| `just vault-init`    | Create vault password file  |
| `just vault-encrypt` | Encrypt `vault/secrets.yml` |
| `just services`      | Show running user services  |
| `just lint`          | Lint playbooks and roles    |
| `just check`         | Syntax check only           |
