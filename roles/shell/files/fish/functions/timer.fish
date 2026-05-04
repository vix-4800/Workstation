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

    set -l escaped_duration (string escape -- $duration)
    set -l escaped_message (string escape -- $message)
    set -l escaped_body (string escape -- "Finished after $duration")

    command fish -c "
        command sleep $escaped_duration

        if command -v notify-send >/dev/null 2>&1
            notify-send --app-name timer $escaped_message $escaped_body >/dev/null 2>&1
        else
            echo $escaped_message >/dev/null
        end

        printf '\\a'
    " >/dev/null 2>&1 &

    disown $last_pid
    echo "Timer started: $duration -> $message"
end
