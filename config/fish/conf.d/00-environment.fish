# ======= Environment =======
set -g fish_greeting ""
set -x EDITOR nvim
set -x VISUAL $EDITOR
set -gx TERM xterm-256color

set -x NODE_VERSION v24.7.0

if not set -q SYSTEM_TYPE
    if is_laptop
        set -gx SYSTEM_TYPE laptop
    else
        set -gx SYSTEM_TYPE desktop
    end
end
