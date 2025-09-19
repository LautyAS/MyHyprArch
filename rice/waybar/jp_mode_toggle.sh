#!/bin/bash
# Módulo Waybar secundario: cambia Romaji ↔ Hiragana/Katakana

state_file="/tmp/waybar_keyboard_state"
layouts=("us(intl)" "latam" "jp")
index=$(cat "$state_file")
layout=${layouts[$index]}

# Solo mostrar si estamos en JP
if [ "$layout" != "jp" ]; then
    echo ""
    exit 0
fi

if [ "$1" = "click" ]; then
    # Alternar Romaji ↔ Hiragana/Katakana
    fcitx5-remote -t
fi

# Mostrar modo actual
mode=$(fcitx5-remote)
if [ "$mode" = "2" ]; then
    echo "{\"text\": \"Romaji\", \"color\": \"#9ca3af\"}"  # gris
else
    echo "{\"text\": \"かな\", \"color\": \"#f97316\"}"    # naranja
fi
