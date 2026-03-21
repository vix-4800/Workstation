---
name: ansible-patterns
description: Ansible role and playbook patterns for idempotent workstation and DevOps automation, including structure, tagging, secrets, and validation workflow.
metadata:
  short-description: Idempotent Ansible patterns for roles, tasks, and validation
---

# Ansible Patterns

Use this skill when implementing or reviewing Ansible changes. The target is predictable, repeatable automation with explicit ownership of packages, config deployment, services, and secrets.

This repository is a workstation state-management repo. Respect its conventions: 2-space indentation, role-plus-type tags, FQCN module names, symlink-based config deployment, and host-specific overrides through inventory and vault files.

## When to Activate

- Adding or refactoring Ansible roles, tasks, handlers, templates, or defaults
- Reviewing idempotency or privilege boundaries
- Deploying configs, packages, or services for workstation setup
- Working with vault-backed templates or host-specific variables
- Validating whether a role change will survive repeated `just apply` runs

## Core Rules

1. Every task must be safe to run repeatedly.
2. Prefer purpose-built modules over `shell` or `command`.
3. Use FQCN module names consistently.
4. Use `become: true` only where system-level mutation requires it.
5. Put reusable defaults in `defaults/main.yml`, not inline literals.

## Repository Conventions

- Tag every task with the role tag plus the most relevant type tag: `packages`, `config`, `services`, or `system`.
- Use `community.general.pacman` for Arch packages and `kewlfft.aur.aur` for AUR installs.
- Deploy dotfiles with `ansible.builtin.file` and `state: link`; `src` points into the repo and `dest` points into the target home directory.
- Use templates for secrets or host-specific values.
- Prefer `ansible.builtin.include_tasks` when a role starts growing multiple concerns.

## Idempotency Checklist

- Does the task converge cleanly on a second run?
- Does it use `creates`, `changed_when`, or `failed_when` where shell commands are unavoidable?
- Does it avoid writing volatile state into the repo or into repo-managed symlink targets?
- Are handlers used for restarts or daemon reloads instead of unconditional restarts in-line?

## Variables And Precedence

- `defaults/main.yml` holds safe defaults.
- `inventory/group_vars` defines shared machine policy.
- `inventory/host_vars/localhost.yml` holds local machine overrides.
- `vault/secrets.yml` holds encrypted secrets only.

Avoid duplicating the same path or setting across defaults, host vars, and templates without a clear precedence reason.

## Anti-Patterns

- `shell` or `command` when a module already exists
- Hardcoded paths that should come from variables like `dotfiles_dir`, `home`, or `username`
- Missing tags, missing `become`, or missing `become: false` for AUR tasks
- Copying configs into place instead of symlinking repo-managed files
- Embedding secrets directly in tracked YAML

## Validation Workflow

- `just check` for syntax validation
- `just plan` for dry-run behaviour
- `just lint` or `ansible-lint` for linting
- `shellcheck roles/*/scripts/*` for bash scripts shipped by roles

## Review Checklist

- Are the tasks idempotent?
- Are privilege boundaries minimal and explicit?
- Are variables and secrets stored in the correct layer?
- Are symlink directions and target paths correct?
- Do tags, handlers, and module choices match repo conventions?
