# Check if this is a laptop by looking for battery and other indicators
# Returns 0 (true) if laptop, 1 (false) if desktop

function is_laptop
    if test -d /sys/class/power_supply/BAT0 -o -d /sys/class/power_supply/BAT1
        return 0
    end

    if test -d /sys/class/power_supply/AC -o -d /sys/class/power_supply/AC0
        return 0
    end

    if test -r /sys/class/dmi/id/chassis_type
        set -l chassis_type (cat /sys/class/dmi/id/chassis_type 2>/dev/null)

        if string match -qr '^(8|9|10|14)$' -- $chassis_type
            return 0
        end
    end

    return 1
end
