.PHONY: help link status doctor ansible

# Default target
help:
	@echo "Dotfiles Management Commands:"
	@echo "  make link       - Apply symlinks from dotfiles.json"
	@echo "  make status     - Check symlink status"
	@echo "  make doctor     - Validate environment"
	@echo "  make ansible    - Run Ansible provisioning"


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
