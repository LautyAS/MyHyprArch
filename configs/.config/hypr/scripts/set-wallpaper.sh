#!/bin/bash

WALL_DIR="$HOME/.config/hypr/wallpapers"
STATE_FILE="$HOME/.config/hypr/state/wallpaper"
THEME=$(cat ~/.config/hypr/state/theme)

# Prioridad: wallpapers del tema → global
#if [ -d "$WALL_DIR/$THEME" ]; then
#    DIR="$WALL_DIR/$THEME"
#else
#    DIR="$WALL_DIR/global"
#fi
#
#mapfile -t WALLS < <(find "$DIR" -type f 2>/dev/null)
#
#if [ ${#WALLS[@]} -eq 0 ]; then
#    echo "No hay wallpapers"
#    exit 1
#fi

DIR="$WALL_DIR/$THEME"

if [ -d "$DIR" ]; then
    mapfile -t WALLS < <(find "$DIR" -type f)
fi

# fallback si está vacío
if [ ${#WALLS[@]} -eq 0 ]; then
    mapfile -t WALLS < <(find "$WALL_DIR/global" -type f)
fi

# si sigue vacío → abortar
if [ ${#WALLS[@]} -eq 0 ]; then
    echo "No hay wallpapers disponibles"
    exit 1
fi


CURRENT=$(cat "$STATE_FILE" 2>/dev/null)

INDEX=0
for i in "${!WALLS[@]}"; do
    if [ "${WALLS[$i]}" == "$CURRENT" ]; then
        INDEX=$i
        break
    fi
done

case "$1" in
    next)
        NEW_INDEX=$(( (INDEX + 1) % ${#WALLS[@]} ))
        ;;
    prev)
        NEW_INDEX=$(( (INDEX - 1 + ${#WALLS[@]}) % ${#WALLS[@]} ))
        ;;
    *)
        NEW_INDEX=0
        ;;
esac

NEW_WALL="${WALLS[$NEW_INDEX]}"

echo "$NEW_WALL" > "$STATE_FILE"

# Posición del cursor (si falla, fallback al centro)
POS=$(hyprctl cursorpos 2>/dev/null)

IFS=',' read -r X Y <<< "$POS"
X=$(echo "$X" | tr -d ' ')
Y=$(echo "$Y" | tr -d ' ')

# altura del monitor activo
MON_HEIGHT=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .height')

# fallback
[ -z "$MON_HEIGHT" ] && MON_HEIGHT=1080

# invertir Y (robusto, soporta floats)
Y_INV=$(awk "BEGIN {print $MON_HEIGHT - $Y}")

# sanity check
if [[ -z "$X" || -z "$Y_INV" ]]; then
    X=960
    Y_INV=540
fi

swww img "$NEW_WALL" \
    --transition-type grow \
    --transition-pos "$X,$Y_INV" \
    --transition-duration 1 \
    --transition-fps 60
