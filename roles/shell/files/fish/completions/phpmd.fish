# Fish completions for phpmd

# Main commands
complete -c phpmd -n '__fish_use_subcommand' -a 'text' -d 'Output format: plain text'
complete -c phpmd -n '__fish_use_subcommand' -a 'xml' -d 'Output format: XML'
complete -c phpmd -n '__fish_use_subcommand' -a 'html' -d 'Output format: HTML'
complete -c phpmd -n '__fish_use_subcommand' -a 'json' -d 'Output format: JSON'
complete -c phpmd -n '__fish_use_subcommand' -a 'ansi' -d 'Output format: ANSI colored text'
complete -c phpmd -n '__fish_use_subcommand' -a 'github' -d 'Output format: GitHub Actions'

# Common rulesets
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a 'cleancode' -d 'Clean code rules'
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a 'codesize' -d 'Code size rules'
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a 'controversial' -d 'Controversial rules'
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a 'design' -d 'Design rules'
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a 'naming' -d 'Naming rules'
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a 'unusedcode' -d 'Unused code rules'

# Global configuration file
complete -c phpmd -n '__fish_seen_subcommand_from text xml html json ansi github' -a "$HOME/.config/phpmd/phpmd.xml" -d 'Global PHPMD configuration'

# Options
complete -c phpmd -l exclude -d 'Comma-separated list of paths to exclude' -x
complete -c phpmd -l suffixes -d 'Comma-separated list of file suffixes to check' -x
complete -c phpmd -l minimum-priority -d 'Rule priority threshold (1-5)' -xa '1 2 3 4 5'
complete -c phpmd -l strict -d 'Enable strict mode'
complete -c phpmd -l ignore-violations-on-exit -d 'Will exit with zero code even when violations are found'
complete -c phpmd -l reportfile -d 'Write report to file instead of stdout' -r
complete -c phpmd -l reportfile-html -d 'Write HTML report to file' -r
complete -c phpmd -l reportfile-text -d 'Write text report to file' -r
complete -c phpmd -l reportfile-xml -d 'Write XML report to file' -r
complete -c phpmd -l baseline-file -d 'Path to baseline file' -r
complete -c phpmd -l generate-baseline -d 'Generate baseline file'
complete -c phpmd -l update-baseline -d 'Update existing baseline file'
complete -c phpmd -l cache -d 'Enable result caching'
complete -c phpmd -l no-cache -d 'Disable result caching'
complete -c phpmd -l cache-file -d 'Location of the cache file' -r
complete -c phpmd -l coverage-report -d 'Path to coverage report (for code coverage integration)' -r
complete -c phpmd -l color -d 'Enable colored output'
complete -c phpmd -l no-color -d 'Disable colored output'
complete -c phpmd -s h -l help -d 'Display help'
complete -c phpmd -s v -l verbose -d 'Increase verbosity'
complete -c phpmd -l version -d 'Display version'
