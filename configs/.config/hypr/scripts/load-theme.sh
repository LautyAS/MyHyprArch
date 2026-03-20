#!/bin/bash

STATE_DIR="$HOME/.config/hypr/state"
THEME=$(cat "$STATE_DIR/theme" 2>/dev/null)
WALL=$(cat "$STATE_DIR/wallpaper" 2>/dev/null)

[ -z "$THEME" ] && THEME="archxp"

# Si no hay wallpaper guardado, agarrar uno
if [ -z "$WALL" ]; then
    DIR="$HOME/.config/hypr/wallpapers/$THEME"
    [ ! -d "$DIR" ] && DIR="$HOME/.config/hypr/wallpapers/global"

    WALL=$(find "$DIR" -type f | shuf -n 1)
fi

# 👇 SIN animación (clave)
swww img "$WALL" --transition-type none
