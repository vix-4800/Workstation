# ======= PATH =======
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.fuelup/bin
fish_add_path $HOME/.opencode/bin

set -l nvm_dir $HOME/.local/share/nvm
if test -d $nvm_dir
    set -l nvm_node (ls -1 $nvm_dir | sort -V | tail -1)
    if test -n "$nvm_node"
        fish_add_path -g $nvm_dir/$nvm_node/bin
    end
end

if test -d $HOME/go/bin
    set -gx GOPATH $HOME/go
    fish_add_path -g $GOPATH/bin
    fish_add_path /usr/local/go/bin
end

if test -d $HOME/.config/composer/vendor/bin
    fish_add_path -g $HOME/.config/composer/vendor/bin
end

if test -d $HOME/.cargo/bin
    fish_add_path -g $HOME/.cargo/bin
end

if test -d $HOME/.local/pipx/venvs
    set -gx PIPX_HOME $HOME/.local/pipx
end

if test -d $HOME/yandex-cloud/bin
    fish_add_path -g $HOME/yandex-cloud/bin
end
