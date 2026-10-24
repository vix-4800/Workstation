function system-upgrade --description 'Full system upgrade: pacman, AUR, flatpak, Fish/Neovim plugins, Mason tools, pipx packages, and CLI tools'
    set -l step 1
    set -l failed_steps 0
    set -l simple_update_specs \
        "Updating official packages (pacman)...|pacman|sudo pacman -Syu --noconfirm|Official packages updated|Pacman update failed|Pacman not installed, cannot continue|true" \
        'Updating AUR packages (yay)...|yay|set -l go_modcache (go env GOMODCACHE); and env GOMODCACHE="$go_modcache" yay -Sua --noconfirm|AUR packages updated|Some AUR packages failed to update|Yay not installed, skipping AUR updates|false' \
        "Updating Flatpak packages...|flatpak|flatpak update -y|Flatpak packages updated|Flatpak update had issues|Flatpak not installed, skipping|false" \
        "Updating Fish shell plugins...|fisher|fisher update|Fish plugins updated|Fish plugin update had issues|Fisher not installed, skipping plugin updates|false" \
        "Updating Claude CLI...|claude|claude update|Claude CLI updated|Claude CLI update had issues|Claude CLI not installed, skipping|false" \
        "Updating OpenCode CLI...|opencode|opencode upgrade|OpenCode CLI updated|OpenCode CLI update had issues|OpenCode CLI not installed, skipping|false" \
        "Updating Copilot CLI...|copilot|copilot update|Copilot CLI updated|Copilot CLI update had issues|Copilot CLI not installed, skipping|false" \
        "Updating global npm packages...|npm|npm -g update|Global npm packages updated|Some npm packages failed to update|NPM not installed, skipping|false" \
        "Updating inifmt...|inifmt|go install github.com/thecrazygm/inifmt@latest|Inifmt updated|Inifmt update failed|Inifmt not installed, skipping|false" \
        "Updating yamlfmt...|yamlfmt|go install github.com/google/yamlfmt/cmd/yamlfmt@latest|Yamlfmt updated|Yamlfmt update failed|Yamlfmt not installed, skipping|false" \
        "Updating just-lsp...|just-lsp|cargo install just-lsp|Just-lsp updated|Just-lsp update failed|Just-lsp not installed, skipping|false" \
        "Checking pinned nginx-lint...|nginx-lint|cargo install --git https://github.com/walf443/nginx-lint --tag v0.10.5 nginx-lint|Nginx-lint matches the repository version|Nginx-lint version check failed|Nginx-lint not installed, skipping|false" \
        "Checking pinned dotenv-linter...|dotenv-linter|cargo install dotenv-linter --version 4.0.0|Dotenv-linter matches the repository version|Dotenv-linter version check failed|Dotenv-linter not installed, skipping|false"
    set -l total_steps (math (count $simple_update_specs) + 4)
    set -l helper_functions _system_upgrade_step _system_upgrade_success \
        _system_upgrade_warning _system_upgrade_error _system_upgrade_version _system_upgrade_run

    # Capture system versions before any updates.
    set -l kernel_before (uname -r)
    set -l kernel_package (pacman -Qoq /usr/lib/modules/$kernel_before/pkgbase 2>/dev/null)
    if test -n "$kernel_package"
        set -l installed_kernel (pacman -Q "$kernel_package" 2>/dev/null | string split ' ')[2]
        if test -n "$installed_kernel"
            set kernel_before $installed_kernel
        end
    end
    set -l fish_before (fish --version | string split ' ')[3]
    set -l python_before ''
    if command -v python >/dev/null
        set python_before (python --version | string split ' ')[2]
    end

    # Colors
    set -l RED (set_color red)
    set -l GRN (set_color green)
    set -l YLW (set_color yellow)
    set -l BLU (set_color blue)
    set -l MAG (set_color magenta)
    set -l CYN (set_color cyan)
    set -l BOLD (set_color --bold)
    set -l OFF (set_color normal)

    function _system_upgrade_step --no-scope-shadowing
        echo
        echo "$BOLD$BLU===>$OFF $BOLD($step/$total_steps)$OFF $argv"
        set step (math $step + 1)
    end

    function _system_upgrade_success --no-scope-shadowing
        echo "$GRN""[OK]$OFF $argv"
    end

    function _system_upgrade_warning --no-scope-shadowing
        echo "$YLW""[WARN]$OFF $argv"
    end

    function _system_upgrade_error --no-scope-shadowing
        echo "$RED""[ERROR]$OFF $argv"
    end

    function _system_upgrade_version
        set -l previous ''
        if test -n "$argv[3]"; and test "$argv[2]" != "$argv[3]"
            set previous " (was: $argv[3])"
        end
        echo "    $argv[1]: $argv[2]$previous"
    end

    function _system_upgrade_run --no-scope-shadowing
        set -l spec $argv[1]
        set -l parts (string split '|' -- $spec)
        set -l title $parts[1]
        set -l command_name $parts[2]
        set -l run_command $parts[3]
        set -l success_message $parts[4]
        set -l failure_message $parts[5]
        set -l missing_message $parts[6]
        set -l fatal_on_failure $parts[7]

        _system_upgrade_step $title
        if command -v $command_name >/dev/null 2>&1; or functions -q $command_name
            if eval $run_command
                _system_upgrade_success $success_message
            else
                if test "$fatal_on_failure" = true
                    _system_upgrade_error $failure_message
                    return 1
                end

                _system_upgrade_error $failure_message
                set failed_steps (math $failed_steps + 1)
            end
        else
            if test "$fatal_on_failure" = true
                _system_upgrade_error $missing_message
                return 1
            end

            _system_upgrade_warning $missing_message
        end

        return 0
    end

    echo "$BOLD$CYN╔════════════════════════════════════════╗$OFF"
    echo "$BOLD$CYN║     Full System Upgrade Started        ║$OFF"
    echo "$BOLD$CYN╚════════════════════════════════════════╝$OFF"

    for simple_update_spec in $simple_update_specs
        if not _system_upgrade_run $simple_update_spec
            functions -e $helper_functions
            return 1
        end
    end

    set -l nvim_config_home "$HOME/.config"
    if set -q XDG_CONFIG_HOME; and test -n "$XDG_CONFIG_HOME"
        set nvim_config_home "$XDG_CONFIG_HOME"
    end
    set -l nvim_app nvim
    if set -q NVIM_APPNAME; and test -n "$NVIM_APPNAME"
        set nvim_app "$NVIM_APPNAME"
    end
    for manager in lazy mason
        _system_upgrade_step "Updating Neovim $manager packages..."
        if not command -v nvim >/dev/null
            _system_upgrade_warning "Neovim not installed, skipping $manager updates"
        else if not test -f "$nvim_config_home/$nvim_app/lua/config/upgrade.lua"
            _system_upgrade_warning "Neovim upgrade configuration not found, skipping $manager updates"
        else if nvim --headless -u NONE -i NONE -c "lua require('config.upgrade').run(\"$manager\")"
            _system_upgrade_success "Neovim $manager packages updated"
        else
            _system_upgrade_error "Neovim $manager update failed"
            set failed_steps (math $failed_steps + 1)
        end
    end

    # Reinstall pipx packages (handles Python version updates)
    _system_upgrade_step "Checking and reinstalling pipx packages..."
    if command -v pipx >/dev/null
        set -l pipx_status (pipx list 2>&1)
        set -l pipx_list_status $status
        set -l python_changed false
        if test -n "$python_before"; and command -v python >/dev/null
            set -l python_after (python --version | string split ' ')[2]
            if test (string match -r '^[0-9]+\.[0-9]+' -- "$python_before") != (string match -r '^[0-9]+\.[0-9]+' -- "$python_after")
                set python_changed true
            end
        end
        if string match -qr '(missing|invalid).*interpreter' -- $pipx_status; or test "$python_changed" = true
            echo "$YLW  Found broken pipx packages, reinstalling...$OFF"
            if pipx reinstall-all
                _system_upgrade_success "All pipx packages reinstalled"
            else
                _system_upgrade_error "Failed to reinstall pipx packages"
                set failed_steps (math $failed_steps + 1)
            end
        else if test $pipx_list_status -ne 0
            _system_upgrade_error "Failed to inspect pipx packages: $pipx_status"
            set failed_steps (math $failed_steps + 1)
        else
            # Just upgrade existing packages
            if pipx upgrade-all
                _system_upgrade_success "All pipx packages upgraded"
            else
                _system_upgrade_error "Some pipx upgrades failed"
                set failed_steps (math $failed_steps + 1)
            end
        end
    else
        _system_upgrade_warning "Pipx not installed, skipping"
    end

    # Update PHP composer global packages
    _system_upgrade_step "Updating global Composer packages..."
    if command -v composer >/dev/null
        set -l composer_home (composer config --global home)
        set -l composer_home_status $status
        if test $composer_home_status -ne 0
            _system_upgrade_error "Failed to locate the Composer global directory"
            set failed_steps (math $failed_steps + 1)
        else if test -f "$composer_home/composer.json"
            if composer global update
                _system_upgrade_success "Global Composer packages updated"
            else
                _system_upgrade_error "Some Composer packages failed to update"
                set failed_steps (math $failed_steps + 1)
            end
        else
            _system_upgrade_warning "Composer global project not found, skipping"
        end
    else
        _system_upgrade_warning "Composer not installed, skipping"
    end

    # Final cleanup
    echo
    if test $failed_steps -eq 0
        _system_upgrade_success "System Upgrade Completed!"
    else
        _system_upgrade_error "System upgrade incomplete: $failed_steps update step(s) failed"
    end
    echo
    echo "$MAG  System information:$OFF"
    set -l kernel_after (uname -r)
    if test -n "$kernel_package"
        set -l installed_kernel (pacman -Q "$kernel_package" 2>/dev/null | string split ' ')[2]
        if test -n "$installed_kernel"
            set kernel_after $installed_kernel
        end
    end
    _system_upgrade_version Kernel "$kernel_after" "$kernel_before"
    _system_upgrade_version Fish "$(fish --version | string split ' ')[3]" "$fish_before"
    if command -v python >/dev/null
        _system_upgrade_version Python "$(python --version | string split ' ')[2]" "$python_before"
    end
    echo
    echo "$CYN  Next steps:$OFF"
    echo "    - Review any warnings above"
    echo "    - Check if reboot is needed: $BOLD ls /usr/lib/modules $OFF"
    echo "    - Test critical applications"
    echo
    functions -e $helper_functions
    if test $failed_steps -gt 0
        return 1
    end
    return 0
end
