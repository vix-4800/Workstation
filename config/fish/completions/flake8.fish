# Fish completions for flake8 (Python linter)

complete -c flake8 -s h -l help -d 'Show help message and exit'
complete -c flake8 -s v -l verbose -d 'Print more information (repeatable)'
complete -c flake8 -l output-file -d 'Redirect report to file' -r
complete -c flake8 -l append-config -d 'Provide extra config files' -r
complete -c flake8 -l config -d 'Path to authoritative config file' -r
complete -c flake8 -l isolated -d 'Ignore all configuration files'
complete -c flake8 -l enable-extensions -d 'Enable plugins/extensions' -x
complete -c flake8 -l require-plugins -d 'Require specific plugins' -x
complete -c flake8 -l version -d 'Show version number and exit'
complete -c flake8 -s q -l quiet -d 'Report only filenames or nothing (repeatable)'
complete -c flake8 -l color -d 'Use color in output' -xa 'auto always never'
complete -c flake8 -l count -d 'Print total number of errors'
complete -c flake8 -l exclude -d 'Comma-separated files/directories to exclude' -x
complete -c flake8 -l extend-exclude -d 'Additional files/directories to exclude' -x
complete -c flake8 -l filename -d 'Only check matching filenames' -x
complete -c flake8 -l stdin-display-name -d 'Name for stdin errors' -x
complete -c flake8 -l format -d 'Error format (default, pylint, quiet-filename)' -xa 'default pylint quiet-filename quiet-nothing'
complete -c flake8 -l hang-closing -d 'Hang closing bracket'
complete -c flake8 -l ignore -d 'Comma-separated error codes to ignore' -x
complete -c flake8 -l extend-ignore -d 'Additional error codes to ignore' -x
complete -c flake8 -l per-file-ignores -d 'File-specific error codes to ignore' -x
complete -c flake8 -l max-line-length -d 'Maximum allowed line length' -x
complete -c flake8 -l max-doc-length -d 'Maximum allowed doc line length' -x
complete -c flake8 -l indent-size -d 'Spaces used for indentation (default: 4)' -x
complete -c flake8 -l select -d 'Limit to these error codes' -x
complete -c flake8 -l extend-select -d 'Add error codes to default select' -x
complete -c flake8 -l disable-noqa -d 'Disable effect of "# noqa"'
complete -c flake8 -l show-source -d 'Show source for each error/warning'
complete -c flake8 -l no-show-source -d 'Do not show source'
complete -c flake8 -l statistics -d 'Count errors'
complete -c flake8 -l exit-zero -d 'Exit with code 0 even if errors'
complete -c flake8 -s j -l jobs -d 'Number of parallel subprocesses (default: auto)' -x
complete -c flake8 -l tee -d 'Write to stdout and output-file'
complete -c flake8 -l benchmark -d 'Print benchmark information'
complete -c flake8 -l bug-report -d 'Print bug report information'

# mccabe plugin
complete -c flake8 -l max-complexity -d 'McCabe complexity threshold' -x

# pyflakes plugin
complete -c flake8 -l builtins -d 'Define more built-ins (comma-separated)' -x
complete -c flake8 -l doctests -d 'Check syntax of doctests'
