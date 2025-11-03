# Fish completions for mypy (Python static type checker)

# Optional arguments
complete -c mypy -s h -l help -d 'Show help message and exit'
complete -c mypy -s v -l verbose -d 'More verbose messages'
complete -c mypy -s V -l version -d 'Show program\'s version number'
complete -c mypy -s O -l output -d 'Set custom output format' -x

# Config file
complete -c mypy -l config-file -d 'Configuration file with [mypy] section' -r
complete -c mypy -l warn-unused-configs -d 'Warn about unused config sections'
complete -c mypy -l no-warn-unused-configs -d 'Do not warn about unused config sections'

# Import discovery
complete -c mypy -l no-namespace-packages -d 'Disable namespace packages (PEP 420)'
complete -c mypy -l namespace-packages -d 'Enable namespace packages'
complete -c mypy -l ignore-missing-imports -d 'Silently ignore imports of missing modules'
complete -c mypy -l follow-untyped-imports -d 'Typecheck modules without stubs'
complete -c mypy -l follow-imports -d 'How to treat imports' -xa 'normal silent skip error'
complete -c mypy -l python-executable -d 'Python executable for finding PEP 561 packages' -r
complete -c mypy -l no-site-packages -d 'Do not search for installed PEP 561 packages'
complete -c mypy -l no-silence-site-packages -d 'Do not silence errors in installed packages'

# Platform configuration
complete -c mypy -l python-version -d 'Python version to assume (e.g. 3.11)' -x
complete -c mypy -l platform -d 'OS platform to assume' -x
complete -c mypy -l always-true -d 'Variable to consider True' -x
complete -c mypy -l always-false -d 'Variable to consider False' -x

# Disallow dynamic typing
complete -c mypy -l disallow-any-expr -d 'Disallow all expressions with type Any'
complete -c mypy -l disallow-any-decorated -d 'Disallow Any in signature after decorator'
complete -c mypy -l disallow-any-explicit -d 'Disallow explicit Any in type positions'
complete -c mypy -l disallow-any-generics -d 'Disallow generic types without explicit parameters'
complete -c mypy -l allow-any-generics -d 'Allow generic types without explicit parameters'
complete -c mypy -l disallow-any-unimported -d 'Disallow Any from unfollowed imports'
complete -c mypy -l allow-any-unimported -d 'Allow Any from unfollowed imports'
complete -c mypy -l disallow-subclassing-any -d 'Disallow subclassing Any'
complete -c mypy -l allow-subclassing-any -d 'Allow subclassing Any'

# Untyped definitions and calls
complete -c mypy -l disallow-untyped-calls -d 'Disallow calling untyped functions from typed'
complete -c mypy -l allow-untyped-calls -d 'Allow calling untyped functions'
complete -c mypy -l untyped-calls-exclude -d 'Disable --disallow-untyped-calls for module' -x
complete -c mypy -l disallow-untyped-defs -d 'Disallow functions without type annotations'
complete -c mypy -l allow-untyped-defs -d 'Allow functions without type annotations'
complete -c mypy -l disallow-incomplete-defs -d 'Disallow incomplete type annotations'
complete -c mypy -l allow-incomplete-defs -d 'Allow incomplete type annotations'
complete -c mypy -l check-untyped-defs -d 'Type check interior of untyped functions'
complete -c mypy -l no-check-untyped-defs -d 'Do not type check untyped functions'
complete -c mypy -l disallow-untyped-decorators -d 'Disallow untyped decorators'
complete -c mypy -l allow-untyped-decorators -d 'Allow untyped decorators'

# None and Optional handling
complete -c mypy -l implicit-optional -d 'Assume arguments with None default are Optional'
complete -c mypy -l no-implicit-optional -d 'Do not assume implicit Optional'
complete -c mypy -l no-strict-optional -d 'Disable strict Optional checks'
complete -c mypy -l strict-optional -d 'Enable strict Optional checks'

# Configuring warnings
complete -c mypy -l warn-redundant-casts -d 'Warn about redundant casts'
complete -c mypy -l no-warn-redundant-casts -d 'Do not warn about redundant casts'
complete -c mypy -l warn-unused-ignores -d 'Warn about unneeded type:ignore comments'
complete -c mypy -l no-warn-unused-ignores -d 'Do not warn about unused ignores'
complete -c mypy -l no-warn-no-return -d 'Do not warn about missing returns'
complete -c mypy -l warn-no-return -d 'Warn about missing returns'
complete -c mypy -l warn-return-any -d 'Warn about returning Any from non-Any functions'
complete -c mypy -l no-warn-return-any -d 'Do not warn about return Any'
complete -c mypy -l warn-unreachable -d 'Warn about unreachable statements'
complete -c mypy -l no-warn-unreachable -d 'Do not warn about unreachable code'

# Miscellaneous strictness
complete -c mypy -l allow-untyped-globals -d 'Suppress toplevel errors from missing annotations'
complete -c mypy -l disallow-untyped-globals -d 'Disallow untyped globals'
complete -c mypy -l allow-redefinition -d 'Allow variable redefinition with new type'
complete -c mypy -l disallow-redefinition -d 'Disallow variable redefinition'
complete -c mypy -l no-implicit-reexport -d 'Treat imports as private unless aliased'
complete -c mypy -l implicit-reexport -d 'Allow implicit reexports'
complete -c mypy -l strict-equality -d 'Prohibit equality checks for non-overlapping types'
complete -c mypy -l no-strict-equality -d 'Allow equality checks for non-overlapping types'
complete -c mypy -l strict -d 'Strict mode (enables many strict flags)'
complete -c mypy -l disable-error-code -d 'Disable specific error code' -x
complete -c mypy -l enable-error-code -d 'Enable specific error code' -x

# Configuring error messages
complete -c mypy -l show-error-context -d 'Show context in error messages'
complete -c mypy -l hide-error-context -d 'Hide context in error messages'
complete -c mypy -l show-column-numbers -d 'Show column numbers'
complete -c mypy -l hide-column-numbers -d 'Hide column numbers'
complete -c mypy -l show-error-end -d 'Show end line/column numbers'
complete -c mypy -l hide-error-end -d 'Hide end line/column numbers'
complete -c mypy -l hide-error-codes -d 'Hide error codes'
complete -c mypy -l show-error-codes -d 'Show error codes'
complete -c mypy -l show-error-code-links -d 'Show links to error documentation'
complete -c mypy -l hide-error-code-links -d 'Hide error code links'
complete -c mypy -l pretty -d 'Use visually nicer output'
complete -c mypy -l no-pretty -d 'Use plain output'
complete -c mypy -l no-color-output -d 'Do not colorize error messages'
complete -c mypy -l color-output -d 'Colorize error messages'
complete -c mypy -l no-error-summary -d 'Do not show error summary'
complete -c mypy -l error-summary -d 'Show error summary'
complete -c mypy -l show-absolute-path -d 'Show absolute paths to files'
complete -c mypy -l hide-absolute-path -d 'Show relative paths to files'

# Incremental mode
complete -c mypy -l no-incremental -d 'Disable module cache'
complete -c mypy -l incremental -d 'Enable module cache'
complete -c mypy -l cache-dir -d 'Store cache in given folder' -r
complete -c mypy -l sqlite-cache -d 'Use sqlite database for cache'
complete -c mypy -l no-sqlite-cache -d 'Do not use sqlite cache'
complete -c mypy -l cache-fine-grained -d 'Include fine-grained dependency info in cache'
complete -c mypy -l skip-version-check -d 'Allow cache from older mypy version'
complete -c mypy -l skip-cache-mtime-checks -d 'Skip cache consistency checks'

# Advanced options
complete -c mypy -l pdb -d 'Invoke pdb on fatal error'
complete -c mypy -l show-traceback -l tb -d 'Show traceback on fatal error'
complete -c mypy -l raise-exceptions -d 'Raise exception on fatal error'
complete -c mypy -l custom-typing-module -d 'Use custom typing module' -x
complete -c mypy -l custom-typeshed-dir -d 'Use custom typeshed directory' -r
complete -c mypy -l warn-incomplete-stub -d 'Warn about missing annotations in typeshed'
complete -c mypy -l no-warn-incomplete-stub -d 'Do not warn about incomplete stubs'
complete -c mypy -l shadow-file -d 'Read SHADOW_FILE instead of SOURCE_FILE' -x

# Report generation
complete -c mypy -l any-exprs-report -d 'Generate any-exprs report' -r
complete -c mypy -l cobertura-xml-report -d 'Generate cobertura XML report' -r
complete -c mypy -l html-report -d 'Generate HTML report' -r
complete -c mypy -l linecount-report -d 'Generate linecount report' -r
complete -c mypy -l linecoverage-report -d 'Generate linecoverage report' -r
complete -c mypy -l lineprecision-report -d 'Generate lineprecision report' -r
complete -c mypy -l txt-report -d 'Generate text report' -r
complete -c mypy -l xml-report -d 'Generate XML report' -r
complete -c mypy -l xslt-html-report -d 'Generate XSLT HTML report' -r
complete -c mypy -l xslt-txt-report -d 'Generate XSLT text report' -r

# Miscellaneous
complete -c mypy -l junit-xml -d 'Write junit.xml to file' -r
complete -c mypy -l find-occurrences -d 'Print usages of class member' -x
complete -c mypy -l scripts-are-modules -d 'Script x becomes module x'
complete -c mypy -l install-types -d 'Install missing stub packages'
complete -c mypy -l no-install-types -d 'Do not install types'
complete -c mypy -l non-interactive -d 'Install stubs without confirmation'
complete -c mypy -l interactive -d 'Ask confirmation for installing stubs'

# Running code
complete -c mypy -l explicit-package-bases -d 'Use cwd and MYPYPATH for module names'
complete -c mypy -l no-explicit-package-bases -d 'Do not use explicit package bases'
complete -c mypy -l exclude -d 'Regex to exclude files/directories' -x
complete -c mypy -s m -l module -d 'Type-check module' -x
complete -c mypy -s p -l package -d 'Type-check package recursively' -x
complete -c mypy -s c -l command -d 'Type-check program passed as string' -x
