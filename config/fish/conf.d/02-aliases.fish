# ======= Aliases =======
alias vim 'nvim'
alias vi 'nvim'
alias neovim 'nvim'
alias ls 'eza --color=auto --group-directories-first --icons=always'
alias ll 'eza -la --color=auto --group-directories-first --icons=always'
alias tree 'eza --tree'
alias cat 'bat'
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

alias ws "workstation"
