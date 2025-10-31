# ======= Aliases =======
alias vim 'nvim'
alias vi 'nvim'
alias neovim 'nvim'

alias grep 'rg'
alias find 'fd'

if command -v eza >/dev/null
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias lt='eza --tree --icons --group-directories-first'
else
    alias ll='ls -lh'
    alias la='ls -lah'
end

if command -v bat >/dev/null
    alias cat='bat --style=auto'
end

if command -v pacman >/dev/null 2>&1
    alias system-cleanup 'sudo pacman -Rns $(pacman -Qtdq)'
end

# Only for wayland
if test "$XDG_SESSION_TYPE" = "wayland"
    alias code "code --ozone-platform=wayland"
    alias spotify "spotify --ozone-platform=wayland"
end

# System management
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
