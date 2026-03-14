function system-upgrade --description 'Full system upgrade: pacman, AUR, flatpak, fish plugins, and pipx packages'
    set -l step 1
    set -l total_steps 9

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

    echo "$BOLD$CYN╔════════════════════════════════════════╗$OFF"
    echo "$BOLD$CYN║     Full System Upgrade Started        ║$OFF"
    echo "$BOLD$CYN╚════════════════════════════════════════╝$OFF"

    # Step 1: Update pacman mirrors with reflector
    print_step "Updating pacman mirrors with reflector..."
    if command -v reflector >/dev/null
        if sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
            print_success "Mirrors updated successfully"
        else
            print_warning "Failed to update mirrors, continuing anyway..."
        end
    else
        print_warning "Reflector not installed, skipping mirror update"
    end

    # Step 2: Update official packages with pacman
    print_step "Updating official packages (pacman)..."
    if sudo pacman -Syu --noconfirm
        print_success "Official packages updated"
    else
        print_error "Pacman update failed"
        return 1
    end

    # Step 3: Update AUR packages with yay
    print_step "Updating AUR packages (yay)..."
    if command -v yay >/dev/null
        if yay -Syu --noconfirm
            print_success "AUR packages updated"
        else
            print_warning "Some AUR packages failed to update"
        end
    else
        print_warning "Yay not installed, skipping AUR updates"
    end

    # Step 4: Update flatpak packages
    print_step "Updating Flatpak packages..."
    if command -v flatpak >/dev/null
        if flatpak update -y
            print_success "Flatpak packages updated"
        else
            print_warning "Flatpak update had issues"
        end
    else
        print_warning "Flatpak not installed, skipping"
    end

    # Step 5: Update fish plugins
    print_step "Updating Fish shell plugins..."
    if command -v fisher >/dev/null
        if fisher update
            print_success "Fish plugins updated"
        else
            print_warning "Fish plugin update had issues"
        end
    else
        print_warning "Fisher not installed, skipping plugin updates"
    end

    # Step 6: Reinstall pipx packages (handles Python version updates)
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

    # Step 7: Update npm global packages
    print_step "Updating global npm packages..."
    if command -v npm >/dev/null
        set -l outdated_pkgs (npm -g outdated --parseable --depth=0 | string split '\n' | string map 'string split ":" $argv[0]' | string map '$argv[0]')
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

    # Step 8: Update PHP composer global packages
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

    # Step 9: Clean up orphaned packages
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
