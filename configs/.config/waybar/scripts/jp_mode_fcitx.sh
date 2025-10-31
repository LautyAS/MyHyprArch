#!/bin/bash
# Módulo Waybar secundario: alterna Romaji ↔ Kana en Mozc

state_file="/tmp/waybar_fcitx_state"
index=$(cat "$state_file")

# Solo activo si estamos en Mozc (índice 2)
if [ "$index" -ne 2 ]; then
    echo '{"text": ""}'
    exit 0
fi

if [ "$1" = "click" ]; then
    fcitx5-remote -t
fi

mode=$(fcitx5-remote)
if [ "$mode" = "2" ]; then
    text="あ"
    class_name="hiragana"
else
    text="A"
    class_name="romaji"
fi

printf '{"text": "%s", "class": "%s"}\n' "$text" "$class_name"

