#!/bin/bash
# Módulo Waybar: rota EN / ESP / JP usando fcitx5

inputs=("keyboard-us-intl" "keyboard-latam" "mozc")
state_file="/tmp/waybar_fcitx_state"

# Inicializar índice
[ ! -f "$state_file" ] && echo 0 > "$state_file"
index=$(cat "$state_file")

# Rotar al hacer click
if [ "$1" = "click" ]; then
    index=$(( (index + 1) % ${#inputs[@]} ))
    echo $index > "$state_file"
    fcitx5-remote -s "${inputs[$index]}"
fi

layout=${inputs[$index]}
case $layout in
    "keyboard-us-intl")
        text="🇬🇧"
        class_name="us"
    ;;
    "keyboard-latam")
        text="🇪🇸"
        class_name="es"
    ;;
    "mozc")
        text="🇯🇵"
        class_name="jp"
    ;;
    *)
        text="❓"
        class_name="unknown"
    ;;
esac

# Devolver JSON limpio para Waybar
echo "{\"text\": \"$text\", \"class\": \"$class_name\"}"

