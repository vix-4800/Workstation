# Fish completions for black (Python code formatter)

complete -c black -s c -l code -d 'Format code passed in as string' -x
complete -c black -s l -l line-length -d 'Characters per line to allow (default: 88)' -x
complete -c black -s t -l target-version -d 'Python versions to support' -xa 'py33 py34 py35 py36 py37 py38 py39 py310 py311 py312 py313 py314'
complete -c black -l pyi -d 'Format all files like typing stubs'
complete -c black -l ipynb -d 'Format all files like Jupyter Notebooks'
complete -c black -l python-cell-magics -d 'Add magic to list of python-magics' -x
complete -c black -s x -l skip-source-first-line -d 'Skip first line of source code'
complete -c black -s S -l skip-string-normalization -d 'Don\'t normalize string quotes or prefixes'
complete -c black -s C -l skip-magic-trailing-comma -d 'Don\'t use trailing commas to split lines'
complete -c black -l preview -d 'Enable potentially disruptive style changes'
complete -c black -l unstable -d 'Enable unstable style changes (implies --preview)'
complete -c black -l enable-unstable-feature -d 'Enable specific unstable feature' -xa 'string_processing hug_parens_with_braces_and_square_brackets wrap_long_dict_values_in_parens multiline_string_handling'
complete -c black -l check -d 'Don\'t write files, just return status'
complete -c black -l diff -d 'Output diff instead of writing files'
complete -c black -l color -d 'Show colored diff'
complete -c black -l no-color -d 'Do not show colored diff'
complete -c black -l line-ranges -d 'Format only specified line ranges (START-END)' -x
complete -c black -l fast -d 'Skip AST safety check (faster)'
complete -c black -l safe -d 'Perform AST safety check (default)'
complete -c black -l required-version -d 'Require specific Black version' -x
complete -c black -l exclude -d 'Regex for files/directories to exclude' -x
complete -c black -l extend-exclude -d 'Additional exclusion patterns' -x
complete -c black -l force-exclude -d 'Exclude even when passed explicitly' -x
complete -c black -l stdin-filename -d 'Filename when passing via stdin' -r
complete -c black -l include -d 'Regex for files/directories to include' -x
complete -c black -s W -l workers -d 'Number of parallel workers' -x
complete -c black -s q -l quiet -d 'Stop emitting non-critical output'
complete -c black -s v -l verbose -d 'Emit messages about unchanged/ignored files'
complete -c black -l version -d 'Show version and exit'
complete -c black -l config -d 'Read configuration from file' -r
complete -c black -s h -l help -d 'Show help message and exit'
