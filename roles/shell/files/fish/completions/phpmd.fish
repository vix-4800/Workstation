# Fish completions for PHPMD 3

# Main commands
complete -c phpmd -n '__fish_use_subcommand' -a 'analyze' -d 'Analyze PHP source code'
complete -c phpmd -n '__fish_use_subcommand' -a 'init' -d 'Generate a configuration file'
complete -c phpmd -n '__fish_use_subcommand' -a 'migrate' -d 'Migrate a configuration file'
complete -c phpmd -n '__fish_use_subcommand' -a 'completion' -d 'Generate shell completions'
complete -c phpmd -n '__fish_use_subcommand' -a 'help' -d 'Display command help'
complete -c phpmd -n '__fish_use_subcommand' -a 'list' -d 'List commands'

# Analyze options
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l format -d 'Report format' -xa 'ansi baseline checkstyle github githubcheckruns gitlab html json sarif text xml'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l ruleset -d 'Ruleset name or configuration file (repeatable)' -r -a "cleancode codesize controversial design naming unusedcode $HOME/.config/phpmd/phpmd.yml"
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l exclude -d 'Exclude pattern (repeatable)' -x
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l suffixes -d 'Source file suffix (repeatable)' -x
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l minimum-priority -d 'Rule priority threshold (1-5)' -xa '1 2 3 4 5'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l maximum-priority -d 'Rule priority threshold (1-5)' -xa '1 2 3 4 5'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l strict -d 'Report suppressed violations'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l no-strict -d 'Honor suppressions'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l ignore-errors-on-exit -d 'Exit with zero code even on errors'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l ignore-violations-on-exit -d 'Exit with zero code even when violations are found'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l input-file -d 'File containing paths to analyze' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l progress -d 'Show progress bar'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l no-progress -d 'Hide progress bar'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l threads -d 'Number of parsing threads' -x
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l reportfile-html -d 'Write HTML report to file' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l reportfile-text -d 'Write text report to file' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l reportfile-xml -d 'Write XML report to file' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l reportfile-json -d 'Write JSON report to file' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l baseline-file -d 'Path to baseline file' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l generate-baseline -d 'Generate baseline file'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l update-baseline -d 'Remove stale baseline entries and report new violations'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l cache -d 'Enable result caching'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l no-cache -d 'Disable result caching'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l cache-file -d 'Location of the cache file' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l cache-strategy -d 'Cache invalidation strategy' -xa 'content timestamp'
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l coverage -d 'Clover coverage report' -r
complete -c phpmd -n '__fish_seen_subcommand_from analyze' -l bootstrap -d 'PHP script to load before analysis' -r

# Configuration commands
complete -c phpmd -n '__fish_seen_subcommand_from init migrate' -l output -d 'Output configuration file' -r
complete -c phpmd -n '__fish_seen_subcommand_from init migrate' -l force -d 'Overwrite the output file'
complete -c phpmd -n '__fish_seen_subcommand_from migrate' -l format -d 'Configuration format' -xa 'yml json'
complete -c phpmd -n '__fish_seen_subcommand_from migrate' -l preserve-behavior -d 'Preserve PHPMD 2 threshold behavior'
complete -c phpmd -n '__fish_seen_subcommand_from migrate' -l dry-run -d 'Print the migrated configuration'

# Global options
complete -c phpmd -s h -l help -d 'Display help'
complete -c phpmd -s V -l version -d 'Display version'
complete -c phpmd -s v -l verbose -d 'Increase verbosity'
complete -c phpmd -s q -l quiet -d 'Only display errors'
complete -c phpmd -l silent -d 'Suppress all output'
complete -c phpmd -l ansi -d 'Force ANSI output'
complete -c phpmd -l no-ansi -d 'Disable ANSI output'
complete -c phpmd -s n -l no-interaction -d 'Disable interactive questions'
