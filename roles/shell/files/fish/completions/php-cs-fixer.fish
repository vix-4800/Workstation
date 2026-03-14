# Fish completions for php-cs-fixer

# Main commands
complete -c php-cs-fixer -n '__fish_use_subcommand' -a 'fix' -d 'Fixes a directory or a file'
complete -c php-cs-fixer -n '__fish_use_subcommand' -a 'list' -d 'List commands'
complete -c php-cs-fixer -n '__fish_use_subcommand' -a 'check' -d 'Check code without making changes'
complete -c php-cs-fixer -n '__fish_use_subcommand' -a 'help' -d 'Display help for a command'

# Options for fix command
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l path-mode -d 'Specify path mode' -xa 'override intersection'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l allow-risky -d 'Are risky fixers allowed' -xa 'yes no'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l config -d 'Path to a config file' -r
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l dry-run -d 'Only show which files would be modified'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l rules -d 'List of rules to run against configured paths' -x
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l using-cache -d 'Should cache be used' -xa 'yes no'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l allow-unsupported-php-version -d 'Run on unsupported PHP version' -xa 'yes no'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l cache-file -d 'Path to cache file' -r
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l diff -d 'Print diff for each file'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l format -d 'Output results format' -xa '@auto @auto,txt checkstyle gitlab json junit txt xml'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l stop-on-violation -d 'Stop execution on first violation'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l show-progress -d 'Type of progress indicator' -xa 'bar dots none'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l sequential -d 'Enforce sequential analysis'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -s h -l help -d 'Display help for command'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l silent -d 'Do not output any message'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -s q -l quiet -d 'Only errors are displayed'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -s V -l version -d 'Display application version'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l ansi -d 'Force ANSI output'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -l no-ansi -d 'Disable ANSI output'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -s n -l no-interaction -d 'Do not ask any interactive question'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from fix' -s v -l verbose -d 'Increase verbosity of messages'

# Options for list command
complete -c php-cs-fixer -n '__fish_seen_subcommand_from list' -l raw -d 'Output raw command list'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from list' -l format -d 'Output format' -xa 'txt xml json md'
complete -c php-cs-fixer -n '__fish_seen_subcommand_from list' -l short -d 'Skip describing commands arguments'

# Global options
complete -c php-cs-fixer -s h -l help -d 'Display help'
complete -c php-cs-fixer -s V -l version -d 'Display version'
