---
name: workstation
description: "Manage dotfiles and systemd services using the workstation script. Use when: adding or removing dotfiles entries, symlinking configs, checking symlink status, enabling/disabling services, troubleshooting broken links, bootstrapping a new system, updating dotfiles from git, editing dotfiles.json mappings."
argument-hint: "task to perform (e.g. 'add new config', 'check status', 'enable services')"
---

# Workstation Dotfiles & Services Management

## Overview

The `workstation` script (`bin/workstation`) is the single entrypoint for all dotfiles and systemd service management in this repository. It reads `dotfiles.json` for symlink mappings and `systemd/user/` for service files.

## Command Reference

### Setup & Update

```bash
workstation setup          # Bootstrap on a fresh Arch Linux system (runs Ansible + links + services)
workstation update [-n]    # Pull latest git changes and reapply config
```

### Dotfiles Commands

```bash
workstation dotfiles link [-n] [--json PATH]     # Create/update symlinks
workstation dotfiles unlink [-n] [--json PATH]   # Remove symlinks
workstation dotfiles status [--json PATH]        # Show per-entry link status
workstation dotfiles doctor [--json PATH]        # Validate environment (git, jq, JSON validity)
workstation dotfiles which [--json PATH]         # Show repo and config paths
workstation dotfiles edit [--json PATH]          # Open dotfiles.json in $EDITOR
```

### Services Commands

```bash
workstation services enable-all    # Enable + start all .service and .timer files in systemd/user/
workstation services disable-all   # Stop + disable all services/timers
workstation services status        # Show enabled/active state for each service
workstation services list          # List service file names available in dotfiles
```

### Global Options

| Flag          | Meaning                                           |
| ------------- | ------------------------------------------------- |
| `-n`          | Dry-run: print what would happen, no changes made |
| `--json PATH` | Use an alternate `dotfiles.json`                  |
| `-h, --help`  | Show usage                                        |

## `dotfiles.json` Schema

The config lives at `dotfiles.json` (root of repo) and is validated against `dotfiles.schema.json`.

```jsonc
{
    "$schema": "./dotfiles.schema.json",
    "mappings": [
        {
            "source": "config/fish", // relative to repo root (or absolute)
            "target": "$HOME/.config/fish", // supports $HOME and ~
            "comment": "Fish shell config", // optional, human-readable
            "sudo": false, // optional, default false; true for system paths
            "action": "nmcli-import", // optional; only "nmcli-import" supported (for WireGuard)
        },
    ],
}
```

**Rules:**

- `source` is relative to repo root unless it starts with `/`
- `target` must use `$HOME` (not hardcoded `/home/username`)
- `sudo: true` is required for targets outside `$HOME` (e.g. `/etc/`)
- `action: "nmcli-import"` imports a `wg-quick` `.conf` file via `nmcli` instead of symlinking

## Workflows

### Adding a New Config File

1. Place the file/directory inside the repo (e.g. `config/myapp/`)
2. Add an entry to `dotfiles.json`:

    ```jsonc
    { "source": "config/myapp", "target": "$HOME/.config/myapp", "comment": "MyApp config" }
    ```

3. Validate JSON: `jq empty dotfiles.json`
4. Dry-run: `workstation dotfiles link -n`
5. Apply: `workstation dotfiles link`

### Checking Symlink Health

```bash
workstation dotfiles status
```

Status indicators:

- `✓` — symlink exists and points to correct source
- `✗` — symlink points to wrong target
- `⚠` — a regular file/folder exists (not a symlink)
- `–` — target missing (not linked yet)
- `💀` — broken symlink (source file deleted)

Filter for problems:

```bash
workstation dotfiles status | grep -E '✗|⚠|💀'
```

### Fixing a Broken or Wrong Symlink

```bash
workstation dotfiles status | grep -E '✗|💀'   # identify problems
workstation dotfiles link -n                    # preview fix
workstation dotfiles link                       # apply (backs up existing files automatically)
```

Backups are written to `~/.local/share/dotfiles/backups/` with a timestamp suffix.

### Removing a Config from Management

1. Remove the entry from `dotfiles.json`
2. `workstation dotfiles unlink` to remove the symlink (original file stays in repo)

### Managing Systemd Services

```bash
workstation services list          # see what's available
workstation services enable-all    # enable and start everything
workstation services status        # verify state
```

To add a new service: drop the `.service` or `.timer` file into `systemd/user/`, then run `workstation services enable-all`.

### Bootstrapping a New Machine

```bash
git clone <repo> ~/Code/Workstation && cd ~/Code/Workstation
workstation setup
```

This runs Ansible playbooks, creates all symlinks, and enables all services.

### Updating After a `git pull`

```bash
workstation update -n   # dry-run first
workstation update      # apply
```

## Troubleshooting

| Symptom                              | Fix                                                                                          |
| ------------------------------------ | -------------------------------------------------------------------------------------------- |
| `jq: command not found`              | `sudo pacman -S jq`                                                                          |
| `Source missing: ...`                | File was deleted from repo; remove the mapping from `dotfiles.json`                          |
| Symlink points to wrong target (`✗`) | Run `workstation dotfiles link` to re-create                                                 |
| Service won't enable                 | Check `journalctl --user -xe` and verify the unit file name with `workstation services list` |
| `Invalid JSON`                       | Validate with `jq empty dotfiles.json`, fix syntax errors                                    |
| `workstation: command not found`     | Re-run `workstation dotfiles link` to restore `~/.local/bin/workstation` symlink             |

## Notes

- The script resolves symlinks to find the repo root — it works correctly when called via `~/.local/bin/workstation`
- `bat cache --build` and `fisher update` are run automatically after `dotfiles link`
- WireGuard entries use `action: "nmcli-import"` and require `nmcli` and elevated privileges
