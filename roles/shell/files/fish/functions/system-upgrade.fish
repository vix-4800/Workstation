function system-upgrade --description 'Full system upgrade: pacman, AUR, flatpak, fish plugins, pipx packages, and CLI tools'
    set -l step 1
    set -l simple_update_specs \
        "Updating pacman mirrors with reflector...|reflector|sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist|Mirrors updated successfully|Failed to update mirrors, continuing anyway...|Reflector not installed, skipping mirror update|false" \
        "Updating official packages (pacman)...|pacman|sudo pacman -Syu --noconfirm|Official packages updated|Pacman update failed|Pacman not installed, cannot continue|true" \
        "Updating AUR packages (yay)...|yay|yay -Syu --noconfirm|AUR packages updated|Some AUR packages failed to update|Yay not installed, skipping AUR updates|false" \
        "Updating Flatpak packages...|flatpak|flatpak update -y|Flatpak packages updated|Flatpak update had issues|Flatpak not installed, skipping|false" \
        "Updating Fish shell plugins...|fisher|fisher update|Fish plugins updated|Fish plugin update had issues|Fisher not installed, skipping plugin updates|false" \
        "Updating Claude CLI...|claude|claude update|Claude CLI updated|Claude CLI update had issues|Claude CLI not installed, skipping|false" \
        "Updating OpenCode CLI...|opencode|opencode upgrade|OpenCode CLI updated|OpenCode CLI update had issues|OpenCode CLI not installed, skipping|false" \
        "Updating Copilot CLI...|copilot|copilot update|Copilot CLI updated|Copilot CLI update had issues|Copilot CLI not installed, skipping|false"
    set -l total_steps (math (count $simple_update_specs) + 4)

    # Colors
    set -l RED (set_color red)
    set -l GRN (set_color green)
    set -l YLW (set_color yellow)
    set -l BLU (set_color blue)
    set -l MAG (set_color magenta)
    set -l CYN (set_color cyan)
    set -l BOLD (set_color --bold)
    set -l OFF (set_color normal)

    function print_step
        echo
        echo "$BOLD$BLU===>$OFF $BOLD($step/$total_steps)$OFF $argv"
        set step (math $step + 1)
    end

    function print_success
        echo "$GRN✓$OFF $argv"
    end

    function print_warning
        echo "$YLW⚠$OFF $argv"
    end

    function print_error
        echo "$RED✗$OFF $argv"
    end

    function run_simple_update_step
        set -l spec $argv[1]
        set -l parts (string split '|' -- $spec)
        set -l title $parts[1]
        set -l command_name $parts[2]
        set -l run_command $parts[3]
        set -l success_message $parts[4]
        set -l failure_message $parts[5]
        set -l missing_message $parts[6]
        set -l fatal_on_failure $parts[7]

        print_step $title
        if command -v $command_name >/dev/null 2>&1; or functions -q $command_name
            if eval $run_command
                print_success $success_message
            else
                if test "$fatal_on_failure" = "true"
                    print_error $failure_message
                    return 1
                end

                print_warning $failure_message
            end
        else
            if test "$fatal_on_failure" = "true"
                print_error $missing_message
                return 1
            end

            print_warning $missing_message
        end

        return 0
    end

    echo "$BOLD$CYN╔════════════════════════════════════════╗$OFF"
    echo "$BOLD$CYN║     Full System Upgrade Started        ║$OFF"
    echo "$BOLD$CYN╚════════════════════════════════════════╝$OFF"

    for simple_update_spec in $simple_update_specs
        if not run_simple_update_step $simple_update_spec
            return 1
        end
    end

    # Reinstall pipx packages (handles Python version updates)
    print_step "Checking and reinstalling pipx packages..."
    if command -v pipx >/dev/null
        set -l pipx_status (pipx list 2>&1)
        if string match -q "*invalid interpreter*" $pipx_status
            echo "$YLW  Found broken pipx packages, reinstalling...$OFF"
            if pipx reinstall-all
                print_success "All pipx packages reinstalled"
            else
                print_error "Failed to reinstall pipx packages"
            end
        else
            # Just upgrade existing packages
            if pipx upgrade-all
                print_success "All pipx packages upgraded"
            else
                print_warning "Some pipx upgrades failed"
            end
        end
    else
        print_warning "Pipx not installed, skipping"
    end

    # Update npm global packages
    print_step "Updating global npm packages..."
    if command -v npm >/dev/null
        set -l outdated_pkgs (npm -g outdated --json --depth=0 2>/dev/null | jq -r 'keys[]' 2>/dev/null)
        if test (count $outdated_pkgs) -gt 0
            echo "$YLW  Found outdated npm packages:$OFF"
            for pkg in $outdated_pkgs
                echo "    - $pkg"
            end
            if npm -g update
                print_success "Global npm packages updated"
            else
                print_warning "Some npm packages failed to update"
            end
        else
            print_success "All global npm packages are up to date"
        end
    else
        print_warning "NPM not installed, skipping"
    end

    # Update PHP composer global packages
    print_step "Updating global Composer packages..."
    if command -v composer >/dev/null
        set -l composer_home (composer config --global home)
        if test -d "$composer_home"
            set -l outdated_composer_pkgs (composer global outdated --direct --format=json | jq -r '.installed[] | select(.latest_version != .version) | .name')
            if test (count $outdated_composer_pkgs) -gt 0
                echo "$YLW  Found outdated Composer packages:$OFF"
                for pkg in $outdated_composer_pkgs
                    echo "    - $pkg"
                end
                if composer global update
                    print_success "Global Composer packages updated"
                else
                    print_warning "Some Composer packages failed to update"
                end
            else
                print_success "All global Composer packages are up to date"
            end
        else
            print_warning "Composer global directory not found, skipping"
        end
    else
        print_warning "Composer not installed, skipping"
    end

    # Clean up orphaned packages
    print_step "Cleaning up orphaned packages..."
    set -l orphans (pacman -Qtdq 2>/dev/null)
    if test -n "$orphans"
        echo "$YLW  Found orphaned packages:$OFF"
        for pkg in $orphans
            echo "    - $pkg"
        end
        if sudo pacman -Rns --noconfirm $orphans
            print_success "Orphaned packages removed"
        else
            print_warning "Failed to remove some orphaned packages"
        end
    else
        print_success "No orphaned packages found"
    end

    # Final cleanup
    echo
    echo "$BOLD$GRN╔════════════════════════════════════════╗$OFF"
    echo "$BOLD$GRN║   System Upgrade Completed!            ║$OFF"
    echo "$BOLD$GRN╚════════════════════════════════════════╝$OFF"
    echo
    echo "$MAG  System information:$OFF"
    echo "    Kernel: $(uname -r)"
    echo "    Fish: $(fish --version | string split ' ')[3]"
    if command -v python >/dev/null
        echo "    Python: $(python --version | string split ' ')[2]"
    end
    echo
    echo "$CYN  Next steps:$OFF"
    echo "    • Review any warnings above"
    echo "    • Check if reboot is needed: $BOLD ls /usr/lib/modules $OFF"
    echo "    • Test critical applications"
    echo
end
