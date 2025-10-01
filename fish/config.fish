# ======= Core =======
set -g fish_greeting
set -x EDITOR nvim
set -x VISUAL $EDITOR

if status is-interactive
    if type -q starship
        starship init fish | source
    end
end

# ======= Variables =======
set -x NODE_VERSION v24.7.0

# ======= PATH Configuration =======
fish_add_path /usr/local/go/bin
fish_add_path $HOME/.config/composer/vendor/bin
fish_add_path $HOME/.local/share/nvm/$NODE_VERSION/bin

# ======= Aliases =======
alias vim 'nvim'
alias vi 'nvim'
alias neovim 'nvim'
alias ls 'eza --color=auto --group-directories-first --icons=always'
alias ll 'eza -la --color=auto --group-directories-first --icons=always'
alias tree 'eza --tree'
alias cat 'bat --style=plain'
alias grep 'rg'
alias find 'fd'

if command -v pacman >/dev/null 2>&1
    alias system-cleanup 'sudo pacman -Rns $(pacman -Qtdq)'
end

# only for wayland
if test "$XDG_SESSION_TYPE" = "wayland"
    alias code "code --ozone-platform=wayland"
    alias spotify "spotify --ozone-platform=wayland"
end
