# Completions for workstation script
# ~/.config/fish/completions/workstation.fish

# Disable file completion by default
complete -c workstation -f

# Main commands
complete -c workstation -n "__fish_use_subcommand" -a "setup" -d "Bootstrap dotfiles on a new system"
complete -c workstation -n "__fish_use_subcommand" -a "dotfiles" -d "Manage dotfiles symlinks"
complete -c workstation -n "__fish_use_subcommand" -a "services" -d "Manage systemd services"
complete -c workstation -n "__fish_use_subcommand" -a "help" -d "Show help message"

# Dotfiles subcommands
complete -c workstation -n "__fish_seen_subcommand_from dotfiles" -a "link" -d "Create/update symlinks"
complete -c workstation -n "__fish_seen_subcommand_from dotfiles" -a "unlink" -d "Remove symlinks"
complete -c workstation -n "__fish_seen_subcommand_from dotfiles" -a "status" -d "Show link status"
complete -c workstation -n "__fish_seen_subcommand_from dotfiles" -a "doctor" -d "Environment checks"
complete -c workstation -n "__fish_seen_subcommand_from dotfiles" -a "which" -d "Show repo and config paths"
complete -c workstation -n "__fish_seen_subcommand_from dotfiles" -a "edit" -d "Open config in editor"

# Services subcommands
complete -c workstation -n "__fish_seen_subcommand_from services" -a "enable-all" -d "Enable and start all services/timers"
complete -c workstation -n "__fish_seen_subcommand_from services" -a "disable-all" -d "Disable and stop all services/timers"
complete -c workstation -n "__fish_seen_subcommand_from services" -a "status" -d "Show status of all services/timers"
complete -c workstation -n "__fish_seen_subcommand_from services" -a "list" -d "List all services in dotfiles"

# Global options
complete -c workstation -l json -d "Path to dotfiles.json" -r -F
complete -c workstation -s n -d "Dry-run mode"
complete -c workstation -s h -l help -d "Show help message"
