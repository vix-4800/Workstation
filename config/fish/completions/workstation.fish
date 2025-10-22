# Completions for workstation script
# ~/.config/fish/completions/workstation.fish

# Disable file completion by default
complete -c workstation -f

# Main commands
complete -c workstation -n "__fish_use_subcommand" -a "link" -d "Create/update symlinks"
complete -c workstation -n "__fish_use_subcommand" -a "unlink" -d "Remove symlinks"
complete -c workstation -n "__fish_use_subcommand" -a "status" -d "Show link status"
complete -c workstation -n "__fish_use_subcommand" -a "doctor" -d "Environment checks"
complete -c workstation -n "__fish_use_subcommand" -a "which" -d "Show repo and config paths"
complete -c workstation -n "__fish_use_subcommand" -a "edit" -d "Open config in editor"
complete -c workstation -n "__fish_use_subcommand" -a "service" -d "Manage systemd services"
complete -c workstation -n "__fish_use_subcommand" -a "timers" -d "Manage systemd timers"
complete -c workstation -n "__fish_use_subcommand" -a "help" -d "Show help message"

# Service subcommands
complete -c workstation -n "__fish_seen_subcommand_from service" -a "enable" -d "Enable and start a service/timer"
complete -c workstation -n "__fish_seen_subcommand_from service" -a "disable" -d "Disable and stop a service/timer"
complete -c workstation -n "__fish_seen_subcommand_from service" -a "restart" -d "Restart a service"
complete -c workstation -n "__fish_seen_subcommand_from service" -a "status" -d "Show status of a service"
complete -c workstation -n "__fish_seen_subcommand_from service" -a "list" -d "List all services in dotfiles"
complete -c workstation -n "__fish_seen_subcommand_from service" -a "reload" -d "Reload systemd user daemon"

# Timers subcommands
complete -c workstation -n "__fish_seen_subcommand_from timers" -a "list" -d "Show active timers"
complete -c workstation -n "__fish_seen_subcommand_from timers" -a "setup" -d "Setup health & productivity timers"

# Global options
complete -c workstation -l json -d "Path to dotfiles.json" -r -F
complete -c workstation -s n -d "Dry-run mode"
complete -c workstation -s h -l help -d "Show help message"

# Service/timer names completion for enable/disable/restart/status
function __workstation_list_services
    set -l systemd_dir (dirname (status -f))/../../systemd/user
    if test -d $systemd_dir
        find $systemd_dir -type f \( -name "*.service" -o -name "*.timer" \) -exec basename {} \;
    end
end

complete -c workstation -n "__fish_seen_subcommand_from service; and __fish_seen_subcommand_from enable disable restart status" -a "(__workstation_list_services)"
