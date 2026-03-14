# Fish completions for phpcbf (PHP Code Beautifier and Fixer)

# Scan targets
complete -c phpcbf -l stdin-path -d 'If processing STDIN, the file path that STDIN will be processed as' -r
complete -c phpcbf -l file-list -d 'Check files/directories defined in file (one per line)' -r
complete -c phpcbf -l filter -d 'Check based on predefined file filter (GitModified, GitStaged)' -x
complete -c phpcbf -l ignore -d 'Ignore files based on comma-separated patterns' -x
complete -c phpcbf -l extensions -d 'Check files with specified extensions (comma-separated)' -x
complete -c phpcbf -s l -d 'Check local directory only, no recursion'

# Rule Selection Options
complete -c phpcbf -l standard -d 'Coding standard to use (comma-separated list)' -x
complete -c phpcbf -l sniffs -d 'Comma-separated list of sniff codes to limit scan to' -x
complete -c phpcbf -l exclude -d 'Comma-separated list of sniff codes to exclude' -x
complete -c phpcbf -s i -d 'Show list of installed coding standards'

# Run Options
complete -c phpcbf -l bootstrap -d 'Run specified file(s) before processing begins' -r
complete -c phpcbf -l parallel -d 'Number of files to check simultaneously' -x
complete -c phpcbf -l suffix -d 'Write modified files using this suffix' -x
complete -c phpcbf -s d -d 'Set php.ini value' -x

# Reporting Options
complete -c phpcbf -l report-width -d 'How many columns wide screen reports should be' -x
complete -c phpcbf -l basepath -d 'Strip path from front of file paths in reports' -r
complete -c phpcbf -s w -d 'Include both warnings and errors (default)'
complete -c phpcbf -s n -d 'Do not include warnings (--warning-severity=0)'
complete -c phpcbf -l severity -d 'Minimum severity to display error/warning (default: 5)' -x
complete -c phpcbf -l error-severity -d 'Minimum severity to display error (default: 5)' -x
complete -c phpcbf -l warning-severity -d 'Minimum severity to display warning (default: 5)' -x
complete -c phpcbf -l ignore-annotations -d 'Ignore all "phpcs:..." annotations in code comments'
complete -c phpcbf -l colors -d 'Use colors in screen output'
complete -c phpcbf -l no-colors -d 'Do not use colors in screen output (default)'
complete -c phpcbf -s p -d 'Show progress of the run'
complete -c phpcbf -s q -d 'Quiet mode; disable progress and verbose output'

# Configuration Options
complete -c phpcbf -l encoding -d 'Encoding of files being checked (default: utf-8)' -x
complete -c phpcbf -l tab-width -d 'Number of spaces each tab represents' -x
complete -c phpcbf -l runtime-set -d 'Set configuration for current scan run only' -x

# Miscellaneous Options
complete -c phpcbf -s h -l help -d 'Print help message'
complete -c phpcbf -l version -d 'Print version information'
complete -c phpcbf -s v -d 'Verbose: Print processed files'
