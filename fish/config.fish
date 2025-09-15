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

# ======= PATH Configuration =======
# Add Go binaries
set -gx PATH $PATH /usr/local/go/bin

# Add Composer global binaries
set -gx PATH $PATH $HOME/.config/composer/vendor/bin

# ======= Aliases =======
alias vim 'nvim'
alias vi 'nvim'
alias neovim 'nvim'
alias ls 'ls --color=auto'
alias cleanup 'sudo pacman -Rns $(pacman -Qtdq)'

# only for wayland
if test "$XDG_SESSION_TYPE" = "wayland"
    alias code "code --ozone-platform=wayland"
    alias spotify "spotify --ozone-platform=wayland"
end

function fan
    if test (count $argv) -eq 0
        echo "Usage: fan <speed %>"
        return 1
    end
    sudo nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$argv[1]" --display :0
    echo "Fan speed set to $argv[1]%"
end
