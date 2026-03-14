# Fish completions for phpcs (PHP_CodeSniffer)

# Scan targets
complete -c phpcs -l stdin-path -d 'If processing STDIN, the file path that STDIN will be processed as' -r
complete -c phpcs -l file-list -d 'Check files/directories defined in file (one per line)' -r
complete -c phpcs -l filter -d 'Check based on predefined file filter (GitModified, GitStaged)' -x
complete -c phpcs -l ignore -d 'Ignore files based on comma-separated patterns' -x
complete -c phpcs -l extensions -d 'Check files with specified extensions (comma-separated)' -x
complete -c phpcs -s l -d 'Check local directory only, no recursion'

# Rule Selection Options
complete -c phpcs -l standard -d 'Coding standard to use (comma-separated list)' -x
complete -c phpcs -l sniffs -d 'Comma-separated list of sniff codes to limit scan to' -x
complete -c phpcs -l exclude -d 'Comma-separated list of sniff codes to exclude' -x
complete -c phpcs -s i -d 'Show list of installed coding standards'
complete -c phpcs -s e -d 'Explain a standard by showing sniff names'
complete -c phpcs -l generator -d 'Show documentation for standard' -xa 'HTML Markdown Text'

# Run Options
complete -c phpcs -s a -d 'Run in interactive mode, pausing after each file'
complete -c phpcs -l bootstrap -d 'Run specified file(s) before processing begins' -r
complete -c phpcs -l cache -d 'Cache results between runs' -r
complete -c phpcs -l no-cache -d 'Do not cache results between runs (default)'
complete -c phpcs -l parallel -d 'Number of files to check simultaneously' -x
complete -c phpcs -s d -d 'Set php.ini value' -x

# Reporting Options
complete -c phpcs -l report -d 'Comma-separated list of reports to print' -xa 'full xml checkstyle csv json junit emacs source summary diff svnblame gitblame hgblame notifysend performance'
complete -c phpcs -l report-file -d 'Write report to specified file path' -r
complete -c phpcs -l report-width -d 'How many columns wide screen reports should be' -x
complete -c phpcs -l basepath -d 'Strip path from front of file paths in reports' -r
complete -c phpcs -s w -d 'Include both warnings and errors (default)'
complete -c phpcs -s n -d 'Do not include warnings (--warning-severity=0)'
complete -c phpcs -l severity -d 'Minimum severity to display error/warning (default: 5)' -x
complete -c phpcs -l error-severity -d 'Minimum severity to display error (default: 5)' -x
complete -c phpcs -l warning-severity -d 'Minimum severity to display warning (default: 5)' -x
complete -c phpcs -s s -d 'Show sniff error codes in all reports'
complete -c phpcs -l ignore-annotations -d 'Ignore all "phpcs:..." annotations in code comments'
complete -c phpcs -l colors -d 'Use colors in screen output'
complete -c phpcs -l no-colors -d 'Do not use colors in screen output (default)'
complete -c phpcs -s p -d 'Show progress of the run'
complete -c phpcs -s q -d 'Quiet mode; disable progress and verbose output'
complete -c phpcs -s m -d 'Stop error messages from being recorded'

# Configuration Options
complete -c phpcs -l encoding -d 'Encoding of files being checked (default: utf-8)' -x
complete -c phpcs -l tab-width -d 'Number of spaces each tab represents' -x
complete -c phpcs -l config-show -d 'Show configuration options in CodeSniffer.conf'
complete -c phpcs -l config-set -d 'Save configuration option to CodeSniffer.conf' -x
complete -c phpcs -l config-delete -d 'Delete configuration option from CodeSniffer.conf' -x
complete -c phpcs -l runtime-set -d 'Set configuration for current scan run only' -x

# Miscellaneous Options
complete -c phpcs -s h -l help -d 'Print help message'
complete -c phpcs -l version -d 'Print version information'
complete -c phpcs -s v -d 'Verbose: Print processed files'
