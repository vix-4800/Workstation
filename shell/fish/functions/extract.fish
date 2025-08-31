function extract
    if test (count $argv) -eq 0
        echo "extract <archive.{zip,tar,tar.gz,7z,...}>"
        return 1
    end
    for file in $argv
        if not test -f $file
            echo "File not found: $file"
            continue
        end
        switch $file
            case "*.tar.bz2" "*.tbz2"
                tar xjf -- $file
            case "*.tar.gz" "*.tgz"
                tar xzf -- $file
            case "*.tar"
                tar xf -- $file
            case "*.bz2"
                bunzip2 -- $file
            case "*.gz"
                gunzip -- $file
            case "*.zip"
                unzip -q -- $file
            case "*.7z"
                7z x -- $file
            case "*"
                echo "Unknown format: $file"
        end
    end
end
