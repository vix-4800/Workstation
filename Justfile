# Workstation — machine state management
# Usage: just <recipe>    (e.g. just apply, just plan, just role shell)

set shell := ["bash", "-euo", "pipefail", "-c"]

yml_file := "site.yml"

# Full state apply (packages + configs + services)
apply:
    ansible-playbook {{yml_file}} --ask-become-pass --diff

# Deploy only configs (no package installs, no sudo)
sync:
    ansible-playbook {{yml_file}} --tags config --diff

# Dry-run: show what would change
plan:
    ansible-playbook {{yml_file}} --ask-become-pass --check --diff

# Apply specific role(s): just role shell desktop
role +TAGS:
    ansible-playbook {{yml_file}} --ask-become-pass --tags {{ TAGS }} --diff

# Bootstrap from scratch (first run on a fresh system)
bootstrap:
    sudo pacman -S --needed --noconfirm ansible just
    ansible-galaxy collection install -r requirements.yml
    @just apply

# Install ansible-galaxy requirements
deps:
    ansible-galaxy collection install -r requirements.yml

# Edit encrypted secrets
vault-edit:
    ansible-vault edit vault/secrets.yml

# Create encrypted vault file from example template
vault-encrypt:
    @if [ ! -f vault/secrets.yml ]; then \
        echo "Error: vault/secrets.yml not found. Please create it from vault/secrets.yml.example and add your secrets before encrypting."; \
        exit 1; \
    fi
    ansible-vault encrypt vault/secrets.yml

# Create vault password file (first-time setup)
vault-init:
    @echo "Enter vault password:"
    @read -s pass && echo "$$pass" > .vault-password
    @chmod 600 .vault-password
    @echo "Created .vault-password"

# Show systemd user services status
services:
    systemctl --user list-units --type=service --type=timer --state=running --no-pager

# Lint all playbooks and roles
lint:
    ansible-lint {{yml_file}}

# Validate syntax only
check:
    ansible-playbook {{yml_file}} --syntax-check
