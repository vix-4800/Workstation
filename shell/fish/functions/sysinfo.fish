function sysinfo
    echo (uname -a)
    echo
    if type -q lsb_release
        lsb_release -a 2>/dev/null
    end
    echo
    echo "Shell: (fish --version)"
    echo (fish --version)
end
