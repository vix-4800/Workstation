# Fish completions for phpstan

# Main commands
complete -c phpstan -n '__fish_use_subcommand' -a 'analyse analyze' -d 'Analyses source code'

# Options for analyse/analyze command
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s c -l configuration -d 'Path to project configuration file' -r
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s l -l level -d 'Level of rule options (higher = stricter)' -xa '0 1 2 3 4 5 6 7 8 9'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l no-progress -d 'Do not show progress bar, only results'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l debug -d 'Show debug information, do not catch internal errors'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s a -l autoload-file -d 'Project\'s additional autoload file path' -r
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l error-format -d 'Format for printing analysis result' -xa 'table json checkstyle junit prettyJson gitlab'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s b -l generate-baseline -d 'Path to save baseline file' -r
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l allow-empty-baseline -d 'Do not error when baseline is empty'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l memory-limit -d 'Memory limit for analysis' -x
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l xdebug -d 'Allow running with Xdebug for debugging'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l tmp-file -d '(Editor mode) Edited file used in place of --instead-of' -r
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l instead-of -d '(Editor mode) File being replaced by --tmp-file' -r
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l fix -d 'Fix auto-fixable errors (experimental)'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l watch -d 'Launch PHPStan Pro'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l pro -d 'Launch PHPStan Pro'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l fail-without-result-cache -d 'Return non-zero exit code when result cache not used'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s h -l help -d 'Display help for command'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s q -l quiet -d 'Do not output any message'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s V -l version -d 'Display application version'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l ansi -d 'Force ANSI output'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -l no-ansi -d 'Disable ANSI output'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s n -l no-interaction -d 'Do not ask any interactive question'
complete -c phpstan -n '__fish_seen_subcommand_from analyse analyze' -s v -l verbose -d 'Increase verbosity of messages'

# Global options
complete -c phpstan -s h -l help -d 'Display help'
complete -c phpstan -s V -l version -d 'Display version'
