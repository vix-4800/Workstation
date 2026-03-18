function companion_classify_command --argument-names command_line --description 'Map shell commands to companion moods'
    set -l normalized (string trim -- "$command_line")

    if string match -qr '^(system-cleanup|cleanup|rm |trash-empty|yay -Sc|paccache|docker system prune)' -- "$normalized"
        echo sweep
    else if string match -qr '^(git|jj|lazygit|docker|kubectl|ansible|nvim|vim|hx|ssh)\b' -- "$normalized"
        echo thinking
    else if string match -qr '^(systemctl suspend|suspend|loginctl lock-session)' -- "$normalized"
        echo sleep
    else
        echo react
    end
end
