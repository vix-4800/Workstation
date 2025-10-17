# Use trash-put instead of rm
function rm
    if command -v trash-put >/dev/null 2>&1
        trash-put $argv
    else
        command rm -i $argv
    end
end

# Restore file from trash
function restore
    if command -v trash-restore >/dev/null 2>&1
        trash-restore
    else
        echo "trash-cli is not installed"
    end
end

# List trashed files
function trash-list
    if command -v trash-list >/dev/null 2>&1
        command trash-list
    else
        echo "trash-cli is not installed"
    end
end

# Empty trash
function trash-empty
    if command -v trash-empty >/dev/null 2>&1
        echo "Are you sure you want to empty trash? (y/N)"
        read -l confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
            command trash-empty
            echo "Trash emptied"
        else
            echo "Cancelled"
        end
    else
        echo "trash-cli is not installed"
    end
end
