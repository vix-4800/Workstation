# Workstation — machine state management
# Usage: just <recipe>    (e.g. just apply, just plan, just role shell)

set shell := ["bash", "-euo", "pipefail", "-c"]

yml_file := "site.yml"
vault_args := if path_exists(".vault-password") == "true" { "--vault-password-file .vault-password" } else { "" }

# Full state apply (packages + configs + services)
apply:
    ansible-playbook {{yml_file}} --ask-become-pass --diff {{vault_args}}

# Run config-tagged tasks
sync:
    ansible-playbook {{yml_file}} --ask-become-pass --tags config --diff {{vault_args}}

# Dry-run: show what would change
plan:
    ansible-playbook {{yml_file}} --ask-become-pass --check --diff {{vault_args}}

# Apply specific role(s): just role shell editor
role +TAGS:
    ansible-playbook {{yml_file}} --ask-become-pass --tags "{{ replace(TAGS, " ", ",") }}" --diff {{vault_args}}

# Install ansible-galaxy requirements
deps:
    ansible-galaxy collection install -r requirements.yml

# Edit encrypted secrets
vault-edit:
    ansible-vault edit --vault-password-file .vault-password vault/secrets.yml

# Create encrypted vault file from example template
vault-encrypt:
    @if [ ! -f vault/secrets.yml ]; then \
        echo "Error: vault/secrets.yml not found. Please create it from vault/secrets.yml.example and add your secrets before encrypting."; \
        exit 1; \
    fi
    ansible-vault encrypt --vault-password-file .vault-password vault/secrets.yml

# Create vault password file (first-time setup)
vault-init:
    @umask 077; read -r -s -p 'Enter vault password: ' vault_password && printf '%s\n' "$vault_password" > .vault-password
    @chmod 600 .vault-password
    @printf '\nCreated .vault-password\n'

# Show systemd user services status
services:
    systemctl --user list-units --type=service --type=timer --state=running --no-pager

# Run molecule tests (requires: pip install -r requirements-dev.txt)
molecule:
    molecule test

# Lint all playbooks and roles
lint:
    ansible-lint {{yml_file}}

# Validate syntax only
check:
    ansible-playbook {{yml_file}} --syntax-check
