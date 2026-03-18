if status is-interactive
    function __companion_preexec --on-event fish_preexec
        set -l state (companion_classify_command "$argv[1]")
        companion_emit preexec "$state:$argv[1]"
    end

    function __companion_postexec --on-event fish_postexec
        set -l exit_code $status
        if test $exit_code -eq 0
            companion_emit postexec "success:$exit_code"
        else
            companion_emit postexec "error:$exit_code"
        end
    end

    function __companion_prompt --on-event fish_prompt
        companion_emit prompt idle
    end
end
