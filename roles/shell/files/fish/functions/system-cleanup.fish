function system-cleanup --description 'Clean system caches, orphan packages, and build artifacts'
    # Colors
    set -l RED (set_color red)
    set -l GRN (set_color green)
    set -l YLW (set_color yellow)
    set -l BLU (set_color blue)
    set -l CYN (set_color cyan)
    set -l BOLD (set_color --bold)
    set -l OFF (set_color normal)

    set -l step 1
    set -l total_steps 11
    set -l freed 0

    function _cleanup_step
        echo
        echo "$BOLD$BLU===>$OFF $BOLD($step/$total_steps)$OFF $argv"
        set step (math $step + 1)
    end

    function _cleanup_ok
        echo "$GRN✓$OFF $argv"
    end

    function _cleanup_skip
        echo "$YLW⚠$OFF $argv"
    end

    function _cleanup_err
        echo "$RED✗$OFF $argv"
    end

    echo "$BOLD$CYN╔════════════════════════════════════════╗$OFF"
    echo "$BOLD$CYN║         System Cleanup Started         ║$OFF"
    echo "$BOLD$CYN╚════════════════════════════════════════╝$OFF"

    # Step 1: Remove orphaned packages
    _cleanup_step "Removing orphaned packages..."
    set -l orphans (pacman -Qtdq 2>/dev/null)
    if test -n "$orphans"
        if sudo pacman -Rns $orphans --noconfirm
            _cleanup_ok "Orphaned packages removed"
        else
            _cleanup_err "Failed to remove orphaned packages"
        end
    else
        _cleanup_ok "No orphaned packages found"
    end

    # Step 2: Clean pacman package cache (keep last 2 versions)
    _cleanup_step "Cleaning pacman package cache..."
    if command -v paccache >/dev/null
        if sudo paccache -rk2
            _cleanup_ok "Pacman cache trimmed (kept last 2 versions per package)"
        else
            _cleanup_err "paccache failed"
        end
    else
        _cleanup_skip "paccache not found — install pacman-contrib to enable smart cache trimming"
        _cleanup_skip "Tip: sudo pacman -S pacman-contrib"
    end

    # Step 3: Clean yay / AUR build cache
    _cleanup_step "Cleaning yay AUR build cache..."
    if command -v yay >/dev/null
        yay -Sc --noconfirm 2>&1 | command grep -Ev 'could not open file.*/download-'
        if test $pipestatus[1] -eq 0
            _cleanup_ok "Yay cache cleaned"
        else
            _cleanup_err "Yay cache clean failed"
        end
    else
        _cleanup_skip "Yay not installed, skipping"
    end

    # Step 4: Clean Go build cache
    _cleanup_step "Cleaning Go build cache..."
    if command -v go >/dev/null
        if go clean -cache
            _cleanup_ok "Go build cache cleared"
        else
            _cleanup_err "Go cache clean failed"
        end
    else
        _cleanup_skip "Go not installed, skipping"
    end

    # Step 5: Clean npm cache
    _cleanup_step "Cleaning npm cache..."
    if command -v npm >/dev/null
        if npm cache clean --force 2>/dev/null
            _cleanup_ok "npm cache cleared"
        else
            _cleanup_err "npm cache clean failed"
        end
    else
        _cleanup_skip "npm not installed, skipping"
    end

    # Step 6: Clean uv (Python) cache
    _cleanup_step "Cleaning uv cache..."
    if command -v uv >/dev/null
        set -l uv_tmp (mktemp)
        uv cache clean >$uv_tmp 2>&1 &
        set -l uv_pid $last_pid
        sleep 1
        if grep -q 'in-use' $uv_tmp
            kill $uv_pid 2>/dev/null
            rm -f $uv_tmp
            _cleanup_skip "uv cache is in use by another process, skipping"
        else
            wait $uv_pid
            set -l uv_status $status
            rm -f $uv_tmp
            if test $uv_status -eq 0
                _cleanup_ok "uv cache cleared"
            else
                _cleanup_err "uv cache clean failed"
            end
        end
    else
        _cleanup_skip "uv not installed, skipping"
    end

    # Step 7: Clean pip cache
    _cleanup_step "Cleaning pip cache..."
    if command -v pip >/dev/null
        if pip cache purge 2>/dev/null
            _cleanup_ok "pip cache cleared"
        else
            _cleanup_err "pip cache purge failed"
        end
    else
        _cleanup_skip "pip not installed, skipping"
    end

    # Step 8: Clean pre-commit cache
    _cleanup_step "Cleaning pre-commit cache..."
    if command -v pre-commit >/dev/null
        if pre-commit clean
            _cleanup_ok "pre-commit cache cleared"
        else
            _cleanup_err "pre-commit clean failed"
        end
    else
        _cleanup_skip "pre-commit not installed, skipping"
    end

    # Step 9: Clean composer cache
    _cleanup_step "Cleaning composer cache..."
    if command -v composer >/dev/null
        if composer clearcache --quiet
            _cleanup_ok "Composer cache cleared"
        else
            _cleanup_err "Composer cache clear failed"
        end
    else
        _cleanup_skip "Composer not installed, skipping"
    end

    # Step 10: Clean workstation dotfiles backups
    _cleanup_step "Cleaning workstation dotfiles backups..."
    set -l workstation_backup_dir "$HOME/.local/share/dotfiles/backups"
    if test -d "$workstation_backup_dir"
        set -l backup_entries (find "$workstation_backup_dir" -mindepth 1 -maxdepth 1 2>/dev/null)
        if test (count $backup_entries) -gt 0
            if rm -rf -- $backup_entries
                _cleanup_ok "Workstation backups removed"
            else
                _cleanup_err "Failed to remove workstation backups"
            end
        else
            _cleanup_ok "No workstation backups found"
        end
    else
        _cleanup_ok "No workstation backup directory found"
    end

    # Step 11: Empty trash and clean /tmp
    _cleanup_step "Emptying trash and cleaning /tmp..."
    if command -v trash-empty >/dev/null
        if trash-empty
            _cleanup_ok "Trash emptied"
        else
            _cleanup_err "trash-empty failed"
        end
    else
        _cleanup_skip "trash-empty not installed, skipping trash"
    end

    set -l tmp_entries (find /tmp -mindepth 1 -maxdepth 1 -xdev 2>/dev/null)
    if test (count $tmp_entries) -gt 0
        if sudo find /tmp -mindepth 1 -maxdepth 1 -xdev -exec rm -rf -- '{}' +
            _cleanup_ok "/tmp contents removed"
        else
            _cleanup_err "Failed to clean /tmp"
        end
    else
        _cleanup_ok "/tmp is already empty"
    end

    # Optional: Docker cleanup
    echo
    if command -v docker >/dev/null
        read -l docker_confirm -P "$BOLD$YLW?$OFF $BOLD""[Optional]$OFF Clean Docker images & volumes? [y/N] "
        if string match -qi y -- $docker_confirm
            echo
            echo "$BOLD$BLU===>$OFF $BOLD(optional)$OFF Removing unused Docker images..."
            if docker image prune -a --force
                _cleanup_ok "Unused Docker images removed"
            else
                _cleanup_err "Docker image prune failed"
            end

            echo
            echo "$BOLD$BLU===>$OFF $BOLD(optional)$OFF Removing dangling Docker volumes..."
            if docker volume prune --force
                _cleanup_ok "Dangling Docker volumes removed"
            else
                _cleanup_err "Docker volume prune failed"
            end
        else
            _cleanup_skip "Docker cleanup skipped"
        end
    end

    echo
    echo "$BOLD$CYN╔════════════════════════════════════════╗$OFF"
    echo "$BOLD$CYN║         System Cleanup Complete        ║$OFF"
    echo "$BOLD$CYN╚════════════════════════════════════════╝$OFF"
    echo
    df -h / | awk 'NR==2 {printf "Disk usage: %s used of %s (%s free)\n", $3, $2, $4}'
end
