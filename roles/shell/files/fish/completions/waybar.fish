# Fish completions for waybar

complete -c waybar -s h -l help -d 'Display usage information'
complete -c waybar -s v -l version -d 'Show version'
complete -c waybar -s c -l config -d 'Config path' -r
complete -c waybar -s s -l style -d 'Style path' -r
complete -c waybar -s l -l log-level -d 'Log level' -xa 'trace debug info warning error critical off'
complete -c waybar -s b -l bar -d 'Bar id' -x
