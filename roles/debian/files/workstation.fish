set -g fish_greeting ''
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

set -l config_home "$HOME/.config"
if set -q XDG_CONFIG_HOME[1]
    set config_home "$XDG_CONFIG_HOME"
end
set -gx TAPLO_CONFIG "$config_home/taplo/taplo.toml"
set -l composer_home "$config_home/composer"
if set -q COMPOSER_HOME[1]; and test -n "$COMPOSER_HOME"
    set composer_home "$COMPOSER_HOME"
end
fish_add_path --path "$HOME/.local/bin" "$HOME/go/bin" "$HOME/.cargo/bin" \
    "$HOME/.luarocks/bin" "$composer_home/vendor/bin"

if status is-interactive
    alias vim nvim
    alias vi nvim
    if command -q batcat; and not command -q bat
        alias bat batcat
    end
    if command -q fdfind; and not command -q fd
        alias fd fdfind
    end
    if command -q eza
        alias ls 'eza --icons --group-directories-first'
        alias ll 'eza -l --icons --group-directories-first'
        alias la 'eza -la --icons --group-directories-first'
        alias lt 'eza --tree --icons --group-directories-first'
    end
    alias update 'sudo apt update && sudo apt upgrade'
    alias install 'sudo apt install'
    alias remove 'sudo apt remove'
    alias search 'apt search'
end
