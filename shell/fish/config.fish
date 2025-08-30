if status is-interactive
    if type -q starship
        starship init fish | source
    else
        fish_prompt
    end
end

set -x EDITOR 'code --wait'

set -x PATH $PATH $HOME/bin $HOME/.local/bin /usr/local/bin /usr/local/go/bin $HOME/go/bin /opt/nvim-linux-x86_64/bin
