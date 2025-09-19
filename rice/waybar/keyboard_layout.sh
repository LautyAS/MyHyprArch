#!/bin/bash
# Módulo Waybar principal: cambia EN / ESP / JP

layouts=("us(intl)" "latam" "jp")  # Inglés US Intl, Español Latino, Japonés
state_file="/tmp/waybar_keyboard_state"

# Inicializar
if [ ! -f "$state_file" ]; then
    echo 0 > "$state_file"
fi

index=$(cat "$state_file")

if [ "$1" = "click" ]; then
    # Rotar layout
    index=$(( (index + 1) % ${#layouts[@]} ))
    echo $index > "$state_file"
    layout=${layouts[$index]}

    # Cambiar layout en Hyprland
    hyprctl keyword input:kb_layout "$layout"

    # Activar / desactivar IME
    if [ "$layout" = "jp" ]; then
        fcitx5-remote -o
    else
        fcitx5-remote -c
    fi
else
    layout=${layouts[$index]}
    case $layout in
        "us(intl)") text="EN"; color="#1A195D";;
        "latam") text="ESP"; color="#E9E932";;
        "jp") text="JP"; color="#B30A32";;
    esac

    echo "{\"text\": \"$text\", \"class\": \"$layout\", \"color\": \"$color\"}"
fi

