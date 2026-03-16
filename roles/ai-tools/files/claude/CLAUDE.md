# Claude Code Global Instructions

These instructions apply to Claude Code on this machine unless a repository provides its own `CLAUDE.md`.

## General

- Be direct and concise.
- Read existing code and configuration before editing.
- Make the minimum necessary change for the task.
- Do not create docs or summary files unless explicitly requested.
- Do not add speculative refactors, abstractions, logging, or feature flags.

## Workstation Repositories

- Prefer repository-local instructions from `AGENTS.md` or `CLAUDE.md` when they exist.
- For this workstation setup, treat Ansible roles as the source of truth for packages, configs, and services.
- Prefer symlinked config deployment over copying files when working in the workstation repository.

## Safety

- Never commit or print secrets, tokens, or credentials.
- Treat files under home directories such as caches, histories, backups, and auth state as non-versioned local state unless explicitly asked otherwise.
- Avoid destructive commands unless the user explicitly requests them.
