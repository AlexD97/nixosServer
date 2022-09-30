#!/usr/bin/env bash

b=$(light -G)

icon() {
    # Lets round the float result
    # bri=$(echo "($b+0.5)/1" | bc)
    bri=$(echo "$(brightnessctl get)/$(brightnessctl max)" | bc -l)
    
    if [[ "$bri" -gt "0.90" ]]; then
        echo "󰃠"
        elif [[ "$bri" -gt "0.50" ]]; then
        echo "󰃝"
        elif [[ "$bri" -gt "0.30" ]]; then
        echo "󰃟"
    else
        echo "󰃞"
    fi
}

getbri() {
    bri=$(echo "$(brightnessctl get)/$(brightnessctl max)" | bc -l)
    # bri=$(echo "($b+0.5)/1" | bc)
    echo $bri
}

if [[ $1 == "--icon" ]]; then
    icon
    elif [[ $1 == "--value" ]]; then
    getbri
fi
