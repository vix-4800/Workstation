function timer --description 'Run a background timer and notify when it finishes'
    if test (count $argv) -lt 1
        echo 'Usage: timer <duration> [message]'
        return 1
    end

    set -l duration $argv[1]
    if not string match -rq '^[0-9]+(\.[0-9]+)?(s|m|h|d)?$' -- $duration
        echo "Invalid duration: $duration"
        echo 'Expected format: 30s, 5m, 1.5h, 1d'
        return 1
    end

    set -l message 'Timer finished'
    if test (count $argv) -gt 1
        set message (string join ' ' -- $argv[2..-1])
    end

    begin
        command sleep "$duration"

        if command -v notify-send >/dev/null 2>&1
            notify-send --app-name timer "$message" "Finished after $duration" >/dev/null 2>&1
        else
            echo "$message"
        end

        printf '\a'
    end &

    disown
    echo "Timer started: $duration -> $message"
end
