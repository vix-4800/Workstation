# Completions for dotfiles script
# ~/.config/fish/completions/dotfiles.fish

# Disable file completion by default
complete -c dotfiles -f

# Commands
complete -c dotfiles -n "__fish_use_subcommand" -a "link" -d "Create/update symlinks"
complete -c dotfiles -n "__fish_use_subcommand" -a "unlink" -d "Remove symlinks"
complete -c dotfiles -n "__fish_use_subcommand" -a "status" -d "Show link status"
complete -c dotfiles -n "__fish_use_subcommand" -a "doctor" -d "Environment checks"
complete -c dotfiles -n "__fish_use_subcommand" -a "which" -d "Show repo and config paths"
complete -c dotfiles -n "__fish_use_subcommand" -a "edit" -d "Open config in editor"
complete -c dotfiles -n "__fish_use_subcommand" -a "help" -d "Show help message"

# Options for all commands
complete -c dotfiles -l json -d "Path to dotfiles.json" -r -F

# Dry-run option for link and unlink commands
complete -c dotfiles -n "__fish_seen_subcommand_from link unlink" -s n -d "Dry-run mode"
