# ======= Core =======
set -g fish_greeting
set -x EDITOR 'code --wait'
set -x VISUAL $EDITOR


if status is-interactive
    if type -q starship
        starship init fish | source
    else
        fish_prompt
    end
end


set -x PATH $PATH $HOME/.local/share/nvm/v24.7.0/bin /usr/local/go/bin $HOME/.config/composer/vendor/bin

# ======= Aliases =======
alias vim 'nvim'
alias vi 'nvim'
alias neovim 'nvim'
