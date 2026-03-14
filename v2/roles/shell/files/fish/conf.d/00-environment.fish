# ======= Environment =======

# Disable greeting message
set -g fish_greeting ""

# Editor preferences
set -x EDITOR nvim
set -x VISUAL $EDITOR

# Terminal type
set -gx TERM xterm-256color

if not set -q SYSTEM_TYPE
    if is_laptop
        set -gx SYSTEM_TYPE laptop
    else
        set -gx SYSTEM_TYPE desktop
    end
end

# Pager
set -gx PAGER less
set -gx LESS '-R -F -X -M'
