# Workstation

Machine state management for Arch Linux with Sway and for Debian-family workstations.

Ansible-driven provisioning and configuration for multiple workstations from a single repository.

Ansible detects the OS when you run `just apply`, `just plan`, `just sync` or `just role`.
Arch Linux gets the managed Sway desktop. Debian 12+, Kali Rolling, Ubuntu 24.04+,
Linux Mint 22 and LMDE 6/7 use APT on amd64 or arm64 and keep their existing desktop.
On XFCE, Kitty is configured as the preferred terminal. Other derivatives must be
recognized by Ansible as Debian-family and have a supported package base.

## Quick Start

Follow [Fresh System Setup](#fresh-system-setup) on a new machine.

### Daily usage

```bash
just apply              # Full state: packages + configs + services
just sync               # Run config-tagged tasks
just plan               # Dry-run: show what would change
just role shell         # Apply specific role
just role shell,editor   # Multiple roles
```

### Secrets

```bash
just vault-init         # Create vault password file (first time)
just vault-encrypt      # Encrypt vault/secrets.yml (after adding secrets in plain YAML)
just vault-edit         # Edit encrypted secrets
```

## Fresh System Setup

Run these steps as the local account you want Ansible to configure.

### 1. Prepare the user and sudo

The target user must exist before running this repo and must be allowed to use `sudo`, because `just apply` runs
`ansible-playbook --ask-become-pass`.

On Arch Linux, for example:

```bash
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
EDITOR=vim visudo
```

Enable sudo for the `wheel` group in `/etc/sudoers`:

```text
%wheel ALL=(ALL:ALL) ALL
```

On Debian-family systems, use an account with sudo access, typically through the `sudo` group.
Then log in as the target user.

### 2. Install required packages

On Arch Linux:

```bash
sudo pacman -Syu --needed sudo vim git ansible just base-devel
```

On APT-based systems:

```bash
sudo apt install sudo vim git ansible-core python3-apt
```

The shared playbook needs Ansible Core 2.18 or newer for its pinned collections.
If APT supplies an older release, install a compatible version in a Python virtual environment
and activate it before running the commands below. Use Python 3.11 or newer and keep
`/usr/bin/python3` and `python3-apt` installed for managed tasks.
On Ubuntu-based systems, enable the Universe component. The configured repositories must
provide PHP 8.4 or newer and its extensions, with PHP 8.4 or newer selected at `/usr/bin/php`.
Install `just` from your package manager or an upstream release. The first APT-based run
can also install it when you bootstrap through Ansible.

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

Set `username`, `hostname`, `base_timezone`, `git_user_name` and `git_user_email`.
Use `base_locale` to override the default locale. On Arch Linux, also set
`cpu_vendor`, `gpu_vendor` and `has_battery` for the machine.

### 5. Create vault secrets

Arch Linux requires `vault/secrets.yml`. On Debian-family systems, create it if you want
to provision WireGuard. Set `debian_wireguard_enabled: false` to disable the profile explicitly.

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

If `just` is unavailable, run:

```bash
ansible-galaxy collection install -r requirements.yml
```

### 7. Run the first apply

```bash
just apply
```

On APT-based systems without `just`, bootstrap with `ansible-playbook site.yml --ask-become-pass --diff`.
Add `--vault-password-file .vault-password` when using an encrypted vault. Provisioning installs
`just` into `~/.local/bin` if needed. Subsequent runs use the shared recipes.

Log out and back in to pick up the login shell, tool paths and Docker group membership.
The Docker group grants root-equivalent access. A systemd user session is required
for user timers. Run `gh auth login` if you use HTTPS for Git authentication.

On APT-based systems, check mode uses the current package indexes. Downloads and actions
that require a newly installed program run during application. Docker uses archive packages
and fills in missing Buildx or Compose v2 plugins from upstream releases. If the archive supplies
Git older than 2.54, the playbook builds a verified upstream version in the user's home for the shared hooks.

Obsidian uses APT when available, then the vendor package on amd64 or Flathub on arm64.
Spotify on Flathub is available on amd64. If Snapcraft cannot deliver the download,
the next apply retries it.

## Architecture

### Single tool, single workflow

Everything is managed through **Ansible roles** — packages, configs, services, and secrets. `just` provides a thin UX
layer on top of `ansible-playbook`. `site.yml` gathers Ansible facts and selects the
platform play for each host.

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
| `shell` | Fish, Bash, Kitty (default terminal), Alacritty, Tmux, aliases |
| `editor` | Neovim (with Lua + LuaRocks), VSCode flags, Git config |
| `audio` | PipeWire, WirePlumber, EasyEffects, multimedia apps |
| `network` | Firewall (nftables), Bluetooth (nm-applet + blueman tray flow), WireGuard (vault), V2RayA, USBGuard |
| `desktop` | SwayFX, Waybar, Wofi, SwayNC, GTKLock, Wlogout, polkit-gnome, XDG portals, swappy, wdisplays, qt5/6-wayland |
| `display-manager` | Greetd + ReGreet |
| `development` | PHP, Python, Go, Docker, linter configs |
| `appearance` | GTK themes (nwg-look), fonts, cursors, icons, wallpapers, plymouth |
| `apps` | Obsidian, Bitwarden, file-roller, gvfs-goa, Flatpak + Flathub, waypaper, TLP + Powertop (battery only) |
| `services` | All systemd user services and timers (xdg-user-dirs, etc.) |
| `ai-tools` | Claude Code, Codex, OpenCode, MCP/Serena, agent skills on Arch Linux |
| `debian` | APT packages, shared shell and development configs, Docker, desktop apps, Codex and optional WireGuard on Debian-family systems |

### Laptop power management

On Arch Linux with `has_battery: true`, the `apps` role installs TLP and Powertop, disables existing
`auto-cpufreq` and `power-profiles-daemon` services, masks `power-profiles-daemon` when present
and the systemd rfkill service and socket,
and enables `tlp.service`. The retired `auto-cpufreq` package is no longer installed or enabled;
remove an existing installation with the migration commands below.

TLP uses its built-in power-saving defaults. Ansible deploys `/etc/tlp.d/10-workstation.conf`
with `TLP_ENABLE=1`, `START_CHARGE_THRESH_BAT0=0` and `STOP_CHARGE_THRESH_BAT0=90` to stop
charging the primary battery at 90% on supported hardware. Override `apps_tlp_settings` in local
host vars for hardware-specific settings. Settings in `/etc/tlp.conf` take precedence over this drop-in.
See the [TLP configuration documentation](https://linrunner.de/tlp/settings/introduction.html).

Powertop is installed for interactive diagnostics with `sudo powertop`. It needs no repository
configuration or service. Do not enable `powertop --auto-tune` at boot: it overwrites settings
managed by TLP. See [TLP and Powertop](https://linrunner.de/tlp/faq/powertop.html).

For an existing workstation, migrate before applying the updated roles:

```bash
sudo systemctl disable --now auto-cpufreq.service
sudo pacman -R auto-cpufreq
just role apps,services
systemctl --user daemon-reload
systemctl --user restart batsignal.service
sudo tlp-stat -s
sudo tlp-stat -c
```

The first two commands apply only if `auto-cpufreq` is still installed. The user service restart
loads the corrected batsignal command: notifications at 20% and 10%, and an unplug reminder at
90%. These notification thresholds do not control charging or trigger automatic suspend.

### Tags

Tasks are tagged for granular execution. The common tags are role tags (`desktop`, `network`, `development`, etc.), type
tags (`packages`, `config`, `services`, `system`), and narrower subgroup tags such as `wireguard`, `gtklock`, or `php`.

| Tag           | Scope                                                                 |
| ------------- | --------------------------------------------------------------------- |
| `config`      | Deploy configuration                                                  |
| `system`      | System-level configs requiring sudo (/etc/, /boot/)                   |
| `packages`    | Install packages                                                      |
| `services`    | Manage systemd units                                                  |
| Role tags     | `shell`, `desktop`, `network`, etc.; some tasks use only the role tag |
| Subgroup tags | `wireguard`, `gtklock`, `php`, `docker`, etc.                         |

### Secrets

WireGuard uses encrypted values from `vault/secrets.yml` and local settings from
`inventory/host_vars/localhost.yml`.

Create the vault file like this:

```bash
just vault-init
# create vault/secrets.yml from vault/secrets.yml.example and fill in your values
just vault-encrypt
just vault-edit
```

Before running `just vault-encrypt`, `vault/secrets.yml` may exist temporarily as plain YAML copied from the example.
Keep the file encrypted and store the password separately in `.vault-password` with mode `0600`.
The shared `just` recipes pass the password file to Ansible when it exists.

If you already created `vault/secrets.yml` as plain YAML, re-encrypt it:

```bash
just vault-encrypt
```

You can verify the file is encrypted if the first line starts with:

```text
$ANSIBLE_VAULT;
```

On Arch Linux, the playbook writes `/etc/wireguard/wg0.conf`. On Debian-family systems,
it creates a NetworkManager `wg0` profile. Provide IPv4 and IPv6 addresses in the vault for
a dual-stack tunnel and connect on demand with `nmcli connection up wg0`.

## Structure

```text
├── Justfile                    # Command interface
├── ansible.cfg                 # Ansible settings
├── requirements.yml            # Galaxy collections
├── site.yml                    # Shared entry point and OS detection
├── arch.yml                    # Arch Linux provisioning
├── debian.yml                  # Debian-family provisioning
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

## Sway Desktop Stack on Arch Linux

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
- **WireGuard / V2RayA** — VPN

### Screenshots & Display

- **Swappy** — screenshot annotation
- **wdisplays** — display configuration GUI

### Appearance

- **nwg-look** — GTK theme manager for Wayland
- **Catppuccin Mocha** — consistent colour theme across all components

### Applications

- **Kitty** — default terminal for Sway, Wofi, and Waybar scripts; Fish, JetBrainsMono Nerd Font (14 pt),
  Catppuccin Mocha, 80% background opacity, and 10,000 lines of scrollback.
  The `shell` role links `roles/shell/files/kitty/` to `~/.config/kitty/`.
  See the [Kitty configuration reference](https://sw.kovidgoyal.net/kitty/conf/) for available settings.
- **Alacritty** — remains installed with its existing configuration; available for manual launch.
- **Obsidian** — notes
- **Bitwarden** — password manager
- **File Roller** — archive manager
- **Flatpak + Flathub** — additional applications

## Just Commands

| Command              | Description                 |
| -------------------- | --------------------------- |
| `just apply`         | Full state apply            |
| `just sync`          | Run config-tagged tasks     |
| `just plan`          | Dry-run (check mode)        |
| `just role <tags>`   | Apply specific role(s)      |
| `just deps`          | Install Galaxy collections  |
| `just vault-edit`    | Edit encrypted secrets      |
| `just vault-init`    | Create vault password file  |
| `just vault-encrypt` | Encrypt `vault/secrets.yml` |
| `just services`      | Show running user services  |
| `just molecule`      | Run molecule tests          |
| `just lint`          | Lint playbooks and roles    |
| `just check`         | Syntax check only           |
