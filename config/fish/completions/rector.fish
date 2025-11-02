# Fish completions for rector

# Main command
complete -c rector -n '__fish_use_subcommand' -a 'process' -d 'Upgrades or refactors source code with Rector rules'

# Options for process command
complete -c rector -n '__fish_seen_subcommand_from process' -s n -l dry-run -d 'Only see diff of changes, do not save to files'
complete -c rector -n '__fish_seen_subcommand_from process' -s a -l autoload-file -d 'Path to file with extra autoload' -r
complete -c rector -n '__fish_seen_subcommand_from process' -l no-progress-bar -d 'Hide progress bar (useful for CI)'
complete -c rector -n '__fish_seen_subcommand_from process' -l no-diffs -d 'Hide diffs of changed files (useful for CI)'
complete -c rector -n '__fish_seen_subcommand_from process' -l output-format -d 'Select output format' -xa 'console json'
complete -c rector -n '__fish_seen_subcommand_from process' -l only -d 'Fully qualified rule class name' -x
complete -c rector -n '__fish_seen_subcommand_from process' -l only-suffix -d 'Filter files with specific suffix (e.g. "Controller")' -x
complete -c rector -n '__fish_seen_subcommand_from process' -l debug -d 'Enable debug verbosity (-vvv)'
complete -c rector -n '__fish_seen_subcommand_from process' -l memory-limit -d 'Memory limit for process' -x
complete -c rector -n '__fish_seen_subcommand_from process' -l clear-cache -d 'Clear cache'
complete -c rector -n '__fish_seen_subcommand_from process' -l port -d 'Port number' -x
complete -c rector -n '__fish_seen_subcommand_from process' -l identifier -d 'Identifier' -x
complete -c rector -n '__fish_seen_subcommand_from process' -l xdebug -d 'Allow running xdebug'
complete -c rector -n '__fish_seen_subcommand_from process' -s h -l help -d 'Display help for the command'
complete -c rector -n '__fish_seen_subcommand_from process' -s V -l version -d 'Display application version'
complete -c rector -n '__fish_seen_subcommand_from process' -l ansi -d 'Force ANSI output'
complete -c rector -n '__fish_seen_subcommand_from process' -l no-ansi -d 'Disable ANSI output'
complete -c rector -n '__fish_seen_subcommand_from process' -s c -l config -d 'Path to config file' -r
complete -c rector -n '__fish_seen_subcommand_from process' -s v -l verbose -d 'Increase verbosity of messages'

# Global options
complete -c rector -s h -l help -d 'Display help'
complete -c rector -s V -l version -d 'Display version'
