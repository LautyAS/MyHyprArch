#!/bin/bash
# Módulo Waybar secundario: alterna Romaji ↔ Kana vía fcitx5

state_file="/tmp/waybar_fcitx_state"
index=$(cat "$state_file")

# Solo activo si estamos en Mozc (índice 2)
if [ "$index" -ne 2 ]; then
    echo ""
    exit 0
fi

if [ "$1" = "click" ]; then
    fcitx5-remote -t
fi

# Mostrar estado actual
mode=$(fcitx5-remote)
if [ "$mode" = "2" ]; then
    text="かな"
    color="#f97316"
    tooltip="Modo de entrada Hiragana/Katakana"
else
    text="Romaji"
    color="#9ca3af"
    tooltip="Modo de entrada Romaji"
fi

echo "{\"text\": \"$text\", \"color\": \"$color\", \"tooltip\": \"$tooltip\"}"

