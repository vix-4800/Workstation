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

    echo "Running Rector..."
    rector process "$target"

    echo "Running PHP-CS-Fixer..."
    php-cs-fixer fix "$target"
end
