if status is-interactive
    if type -q starship
        starship init fish | source
    else
        fish_prompt
    end
end

set -x EDITOR 'code --wait'
