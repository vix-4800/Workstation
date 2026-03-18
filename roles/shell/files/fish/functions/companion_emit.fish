function companion_emit --argument-names event payload --description 'Send terminal companion event to FIFO'
    if not status is-interactive
        return 0
    end

    set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")/terminal-companion
    set -l fifo_path "$state_dir/events.fifo"

    if not test -p "$fifo_path"
        return 0
    end

    set -l clean_payload (string replace -a '\n' ' ' -- "$payload")
    command sh -c 'printf "%s\t%s\n" "$1" "$2" > "$3"' sh "$event" "$clean_payload" "$fifo_path" >/dev/null 2>&1 &
end
