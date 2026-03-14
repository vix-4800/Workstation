function fan
    if test (count $argv) -eq 0
        echo "Usage: fan <speed %>"
        return 1
    end
    sudo nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$argv[1]" --display :0
    echo "Fan speed set to $argv[1]%"
end
