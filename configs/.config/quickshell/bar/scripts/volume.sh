#!/bin/bash

vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Extraer número
num=$(echo "$vol" | awk '{print $2}')
percent=$(awk "BEGIN {printf \"%d\", $num * 100}")

# Detectar mute
if echo "$vol" | grep -q MUTED; then
    icon=""
else
    if [ "$percent" -lt 50 ]; then
        icon=""
    else
        icon=""
    fi
fi

echo "$icon $percent%"
