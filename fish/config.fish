# ======= Core =======
set -g fish_greeting
set -x EDITOR nvim
set -x VISUAL $EDITOR

if status is-interactive
    if type -q starship
        starship init fish | source
    else
        fish_prompt
    end
end

# ======= Variables =======
set -x NODE_VERSION v24.7.0

# ======= PATH Configuration =======
set -gx PATH $PATH /usr/local/go/bin
set -gx PATH $PATH $HOME/.config/composer/vendor/bin
set -gx PATH $PATH $HOME/.local/share/nvm/$NODE_VERSION/bin

# ======= Aliases =======
alias vim 'nvim'
alias vi 'nvim'
alias neovim 'nvim'
alias ls 'ls --color=auto'

if command -v pacman >/dev/null 2>&1
    alias cleanup 'sudo pacman -Rns $(pacman -Qtdq)'
end

# only for wayland
if test "$XDG_SESSION_TYPE" = "wayland"
    alias code "code --ozone-platform=wayland"
    alias spotify "spotify --ozone-platform=wayland"
end
