#!/bin/bash
# Módulo Waybar limpio: rota EN / ESP / JP solo vía fcitx5

# Lista de métodos de entrada
inputs=("keyboard-us-intl" "keyboard-latam" "mozc")
state_file="/tmp/waybar_fcitx_state"

# Inicializar si no existe
if [ ! -f "$state_file" ]; then
    echo 0 > "$state_file"
fi

index=$(cat "$state_file")

if [ "$1" = "click" ]; then
    # Rotar al siguiente método
    index=$(( (index + 1) % ${#inputs[@]} ))
    echo $index > "$state_file"

    # Cambiar método activo en fcitx5
    fcitx5-remote -s "${inputs[$index]}"
fi

# Mostrar estado en Waybar
layout=${inputs[$index]}
case $layout in
    "keyboard_us_intl)")
        text="🇺🇸 EN"
        color="#10b981"
        tooltip="US Intl"
    ;;
    "keyboard_latam)")
        text="🇲🇽 ESP"
        color="#3b82f6"
        tooltip="Esp Latam"
    ;;
    "mozc")
        text="🇯🇵 JP"
        color="#ef4444"
        tooltip="Jp"
    ;;
esac

echo "{\"text\": \"$text\", \"class\": \"$layout\", \"color\": \"$color\", \"tooltip\": \"$tooltip\"}"

