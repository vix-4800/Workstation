# ======= Core =======
set -g fish_greeting

# Load common environment variables and PATH from ~/.profile
# Fish needs special handling for POSIX profile files
if test -f ~/.profile
    # Source profile using bash and import environment
    bash -c 'source ~/.profile; env' | while read line
        set item (string split -m 1 '=' $line)
        if test (count $item) -eq 2
            set -gx $item[1] $item[2]
        end
    end
end

if status is-interactive
    if type -q starship
        starship init fish | source
    else
        fish_prompt
    end
end

# ======= Fish-specific Variables =======
set -x NODE_VERSION v24.7.0

# ======= Fish-specific Aliases =======
# Common aliases are loaded via ~/.profile -> ~/.aliases
# Add fish-specific aliases here if needed
