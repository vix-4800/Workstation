# ======= PATH =======
if set -q NODE_VERSION; and test -n "$NODE_VERSION"
    fish_add_path $HOME/.local/share/nvm/$NODE_VERSION/bin
end
fish_add_path $HOME/.fuelup/bin

if test -d $HOME/go/bin
    set -gx GOPATH $HOME/go
    fish_add_path -g $GOPATH/bin
    fish_add_path /usr/local/go/bin
end

if test -d $HOME/.config/composer/vendor/bin
    fish_add_path -g $HOME/.config/composer/vendor/bin
end

if test -d $HOME/.local/pipx/venvs
    set -gx PIPX_HOME $HOME/.local/pipx
end
