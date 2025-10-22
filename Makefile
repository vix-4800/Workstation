.PHONY: help setup link status doctor ansible

# Default target
help:
	@echo "Dotfiles Management Commands:"
	@echo "  make setup      - Bootstrap dotfiles on new system"
	@echo "  make link       - Apply symlinks from dotfiles.json"
	@echo "  make status     - Check symlink status"
	@echo "  make doctor     - Validate environment"
	@echo "  make ansible    - Run Ansible provisioning"

# Bootstrap new system
setup:
	@./bin/workstation setup

# Link dotfiles
link:
	@./bin/workstation link

# Check status
status:
	@./bin/workstation status

# Validate environment
doctor:
	@./bin/workstation doctor

# Run Ansible provisioning
ansible:
	@ansible-playbook ansible/main.yml
