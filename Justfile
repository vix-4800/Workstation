# Workstation — machine state management
# Usage: just <recipe>    (e.g. just apply, just plan, just role shell)

set shell := ["bash", "-euo", "pipefail", "-c"]

host := `cat /etc/hostname`

# Full state apply (packages + configs + services)
apply:
    ansible-playbook site.yml --ask-become-pass --diff

# Deploy only configs (no package installs, no sudo)
sync:
    ansible-playbook site.yml --tags config --diff

# Dry-run: show what would change
plan:
    ansible-playbook site.yml --ask-become-pass --check --diff

# Apply specific role(s): just role shell desktop
role +TAGS:
    ansible-playbook site.yml --tags {{ TAGS }} --diff

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
vault-create:
    test -f vault/secrets.yml && { echo "vault/secrets.yml already exists"; exit 1; } || true
    cp vault/secrets.yml.example /tmp/workstation-secrets.yml
    ansible-vault encrypt --output vault/secrets.yml /tmp/workstation-secrets.yml
    rm -f /tmp/workstation-secrets.yml
    @echo "Created encrypted vault/secrets.yml from vault/secrets.yml.example"

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
    ansible-lint site.yml

# Validate syntax only
check:
    ansible-playbook site.yml --syntax-check
