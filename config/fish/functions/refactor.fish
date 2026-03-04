function refactor --description "Run rector and php-cs-fixer on a file or directory"
    if test (count $argv) -eq 0
        echo "Usage: refactor <file|directory>"
        return 1
    end

    set target $argv[1]

    if not test -e "$target"
        echo "Error: '$target' does not exist"
        return 1
    end

    set rector_out (rector process "$target" --config "$HOME/.config/rector/rector.php" --no-ansi 2>&1)
    set rector_summary (printf '%s\n' $rector_out | grep '\[OK\]' | string trim | string replace '[OK] ' '')

    set fixer_out (php-cs-fixer fix "$target" --config "$HOME/.config/php-cs-fixer/php-cs-fixer.php" --no-ansi 2>&1)
    set fixer_summary (printf '%s\n' $fixer_out | grep '^Fixed' | string replace -r ' in .*' '')

    echo "Rector:       "(test -n "$rector_summary" && echo $rector_summary || echo "no changes")
    echo "PHP-CS-Fixer: "(test -n "$fixer_summary" && echo $fixer_summary || echo "no changes")
end
