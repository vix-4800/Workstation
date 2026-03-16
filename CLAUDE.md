# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

This repository manages workstation state for Arch Linux with Sway using Ansible roles. It is the source of truth for packages, dotfiles, services, secrets templates, and machine-specific configuration.

## Core Conventions

- Use the existing role structure under `roles/`.
- Prefer symlink deployment for user config files.
- Keep changes minimal and scoped to the requested task.
- Do not add README-style documentation unless explicitly requested.
- Never version secrets, auth state, caches, histories, or machine-local runtime data.

## Important Paths

- `site.yml` - master playbook
- `Justfile` - entrypoints for apply/sync/plan workflows
- `inventory/` - tracked shared vars and local machine templates
- `roles/` - all workstation concerns grouped by role
- `vault/secrets.yml.example` - secrets template

## Common Commands

```bash
just apply
just sync
just plan
just lint
just check
pre-commit run -a
shellcheck roles/*/scripts/*
```

## Ansible Notes

- Use 2-space YAML indentation.
- Tag every task with the role tag and a relevant type tag such as `packages`, `config`, `services`, or `system`.
- Use `community.general.pacman` for Arch packages.
- Use `kewlfft.aur.aur` for AUR packages.
- Use `become: true` only where needed.
- Store reusable defaults in `defaults/main.yml` instead of hardcoding values in tasks.

## Shell Script Notes

- Use `#!/usr/bin/env bash`
- Use `set -euo pipefail`
- Do not use Fish syntax in scripts
