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

This repository depends on Galaxy collections declared in [requirements.yml](/requirements.yml),
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

## Remote Servers

The `servers.yml` playbook bootstraps and configures remote Ubuntu servers using the `server-init` role.
It is fully separate from the workstation playbook and uses its own inventory under `inventory/servers/`.

### Prerequisites

- Python 3 on the control machine
- SSH key pair (`~/.ssh/id_ed25519` / `id_ed25519.pub`) on the control machine
- Root SSH access to the target server already configured with your public key
- Ansible collections installed: `ansible-galaxy collection install -r requirements.yml`

### SSH key setup (first time, on the server)

Before running the playbook, copy your public key to the server manually:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@<SERVER_IP>
```

The playbook itself will then disable password authentication on the server permanently.

### Inventory setup

Edit `inventory/servers/hosts.yml` and add your servers. No passwords — key only:

```yaml
all:
  children:
    servers:
      hosts:
        myserver:
          ansible_host: 1.2.3.4
          ansible_user: root
          ansible_port: 22
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
```

Each host must declare its own `ansible_ssh_private_key_file`.

### Running

```bash
# Full initial setup (ssh hardening + update + docker + dev user + ufw)
ansible-playbook servers.yml -i inventory/servers/hosts.yml

# Enable optional services at runtime
ansible-playbook servers.yml -i inventory/servers/hosts.yml \
  -e "server_enable_mtproxy=true"

ansible-playbook servers.yml -i inventory/servers/hosts.yml \
  -e "server_enable_3xui=true"

# Install monitoring script with Telegram notifications
ansible-playbook servers.yml -i inventory/servers/hosts.yml \
  -e "server_enable_monitor=true" \
  -e "server_telegram_bot_token=YOUR_TOKEN" \
  -e "server_telegram_chat_id=YOUR_CHAT_ID"

# Run only a specific step by tag
ansible-playbook servers.yml -i inventory/servers/hosts.yml \
  -t mtproxy -e "server_enable_mtproxy=true"

# Dry-run
ansible-playbook servers.yml -i inventory/servers/hosts.yml --check
```

### Variables

All variables are defined in `roles/server-init/defaults/main.yml` and can be overridden
via `-e` or in `inventory/servers/group_vars/`.

| Variable | Default | Description |
| --- | --- | --- |
| `server_run_update` | `true` | Run `apt update && apt upgrade` |
| `server_install_docker` | `true` | Install `docker.io` and enable the service |
| `server_create_dev_user` | `true` | Create `dev` user in `sudo` and `docker` groups |
| `server_setup_ufw` | `true` | Install and enable `ufw`, allow SSH |
| `server_enable_mtproxy` | `false` | Deploy MTProxy Telegram proxy container |
| `server_enable_3xui` | `false` | Install 3x-ui panel via official install script |
| `server_enable_monitor` | `false` | Deploy daily monitoring script and cron job |
| `server_dev_username` | `dev` | Name of the user to create |
| `server_ssh_public_key_file` | `~/.ssh/id_ed25519.pub` | Public key to deploy to the dev user |
| `server_mtproxy_port` | `443` | Port for MTProxy |
| `server_mtproxy_fake_domain` | `google.com` | Domain used for secret generation |
| `server_mtproxy_ip_prefer` | `prefer-ipv4` | IP preference for MTProxy |
| `server_telegram_bot_token` | `''` | Telegram bot token for monitoring |
| `server_telegram_chat_id` | `''` | Telegram chat ID to send reports to |

### Services

**SSH hardening** — runs on every apply (no bool guard). Sets `PasswordAuthentication no`
and `PermitRootLogin prohibit-password` in `/etc/ssh/sshd_config`, then restarts sshd.

**MTProxy** — Telegram proxy via Docker. After deployment the playbook prints the ready-to-use connection link:

```text
https://t.me/proxy?server=<IP>&port=443&secret=<SECRET>
```

**3x-ui** — XRay-based proxy panel. Installed via the official script.
The installer output is printed at the end of the task.

**Monitoring** — Python script deployed to `/usr/local/bin/server_monitor`.
Sends a daily HTML report to a Telegram chat at 09:00 via cron. The report includes:

- Uptime and load average (1m/5m/15m)
- CPU usage (sampled over 1 second from `/proc/stat`)
- Memory usage (used/total/available)
- Disk usage for `/`
- Network RX/TX totals per interface since boot
- Top 5 processes by CPU and by memory

To get a Telegram bot token, create a bot via [@BotFather](https://t.me/BotFather).
To get your chat ID, send a message to the bot and call `getUpdates` on the bot API.

**Dev user** — created without a password. SSH access for the dev user is configured
via `ansible.posix.authorized_key` using the key from `server_ssh_public_key_file`.

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

| Role | What it manages |
| --- | --- |
| `base` | Locale, hostname, timezone, essential packages (btop, dust, lm_sensors, yq, xdg-utils), env vars, fontconfig, vm.swappiness, paccache.timer |
| `yay` | AUR helper installation |
| `cpu` | CPU microcode (AMD/Intel); thermald thermal management service (Intel only) |
| `gpu` | GPU drivers + fan control (NVIDIA); DRM KMS modprobe and Wayland env config |
| `shell` | Fish, Bash, Alacritty, Tmux, aliases |
| `editor` | Neovim (with Lua + LuaRocks), VSCode flags, Git config |
| `audio` | PipeWire, WirePlumber, EasyEffects, multimedia apps |
| `network` | Firewall (nftables), Bluetooth (nm-applet + blueman tray flow), WireGuard (vault), sing-box, USBGuard |
| `desktop` | SwayFX, Waybar, Wofi, SwayNC, GTKLock, Wlogout, polkit-gnome, XDG portals, swappy, wdisplays, qt5/6-wayland |
| `display-manager` | Greetd + ReGreet |
| `development` | PHP, Python, Go, Docker, linter configs |
| `appearance` | GTK themes (nwg-look), fonts, cursors, icons, wallpapers, plymouth |
| `apps` | Obsidian, Bitwarden, file-roller, gvfs-goa, Flatpak + Flathub, waypaper, auto-cpufreq (battery only) |
| `services` | All systemd user services and timers (xdg-user-dirs, etc.) |
| `ai-tools` | Claude Code, Codex, OpenCode, Qwen, MCP/Serena, agent skills |

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

WireGuard keys are stored in `vault/secrets.yml`, encrypted with `ansible-vault`. Per-host variables in
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

### Core Compositor & Shell

- **SwayFX** — Sway fork with blur, shadows, and rounded corners
- **Waybar** — status bar with custom scripts (weather, Docker, resources, network, audio)
- **Wofi** — launcher and selection menus used by Waybar scripts
- **SwayNC** — notification daemon
- **Greetd + ReGreet** — display manager

### Lock & Session

- **GTKLock** — screen locker with media and background modules
- **Wlogout** — session logout menu
- **polkit-gnome** — authentication agent (autostarted with Sway)
- **xdg-desktop-portal-wlr** — screensharing and file picker portals

### Audio

- **PipeWire + WirePlumber** — audio server
- **EasyEffects** — per-application equaliser and audio effects

### Networking

- **NetworkManager** — connection management
- **network-manager-applet** — tray-based GUI for joining and managing Wi-Fi networks
- **Blueman** — Bluetooth manager plus tray applet for paired devices
- **WireGuard / sing-box** — VPN

### Screenshots & Display

- **Swappy** — screenshot annotation
- **wdisplays** — display configuration GUI

### Appearance

- **nwg-look** — GTK theme manager for Wayland
- **Catppuccin Mocha** — consistent colour theme across all components

### Applications

- **Obsidian** — notes
- **Bitwarden** — password manager
- **File Roller** — archive manager
- **Flatpak + Flathub** — additional applications

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
