#!/bin/bash

THEME_DIR="$HOME/.config/hypr/themes"
STATE_DIR="$HOME/.config/hypr/state"

mapfile -t THEMES < <(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

CURRENT=$(cat "$STATE_DIR/theme" 2>/dev/null)

[ -z "$CURRENT" ] && CURRENT="${THEMES[0]}"

INDEX=0
for i in "${!THEMES[@]}"; do
    if [ "${THEMES[$i]}" == "$CURRENT" ]; then
        INDEX=$i
        break
    fi
done

case "$1" in
    next)
        NEW_INDEX=$(( (INDEX + 1) % ${#THEMES[@]} ))
        ;;
    prev)
        NEW_INDEX=$(( (INDEX - 1 + ${#THEMES[@]}) % ${#THEMES[@]} ))
        ;;
    *)
        for i in "${!THEMES[@]}"; do
            if [ "${THEMES[$i]}" == "$1" ]; then
                NEW_INDEX=$i
                break
            fi
        done
        ;;
esac

NEW_THEME="${THEMES[$NEW_INDEX]}"

# ✅ GUARDAR BIEN
echo "$NEW_THEME" > "$STATE_DIR/theme"

# aplicar modo actual
MODE=$(cat "$STATE_DIR/mode" 2>/dev/null)
[ -z "$MODE" ] && MODE="dark"

ln -sfn "$THEME_DIR/$NEW_THEME/$MODE.conf" "$THEME_DIR/$NEW_THEME/active.conf"
ln -sfn "$THEME_DIR/$NEW_THEME" "$THEME_DIR/current"

# wallpaper automático del tema
~/.config/hypr/scripts/set-wallpaper.sh next

hyprctl reload
