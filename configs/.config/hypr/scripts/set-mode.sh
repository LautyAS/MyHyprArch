#!/bin/bash

MODE=$1
HYPR="$HOME/.config/hypr"

if [ -z "$MODE" ]; then
    echo "Usage: set-mode.sh normal|performance|efficiency"
    exit 1
fi

# Cambiar symlink de modo
ln -sf "$HYPR/modes/$MODE.conf" "$HYPR/modules/mode.conf"

# CPU governor
if [ "$MODE" = "performance" ]; then
    cpupower frequency-set -g performance
    gamemoderun true
elif [ "$MODE" = "efficiency" ]; then
    cpupower frequency-set -g powersave
else
    cpupower frequency-set -g schedutil
fi

# Recargar Hyprland
hyprctl reload

# Notificación
notify-send "Hyprland Mode" "Modo cambiado a $MODE"
