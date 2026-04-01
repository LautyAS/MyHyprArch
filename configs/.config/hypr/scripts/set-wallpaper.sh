#!/bin/bash

WALL_DIR="$HOME/.config/hypr/wallpapers"
CACHE_DIR="$HOME/.cache/hypr"
INDEX_FILE="$CACHE_DIR/wallpaper_index"

mkdir -p "$CACHE_DIR"

# Lista ordenada de wallpapers
mapfile -t WALLS < <(find "$WALL_DIR" -type f | sort)

TOTAL=${#WALLS[@]}
[ "$TOTAL" -eq 0 ] && exit 1

# Leer índice actual
if [ -f "$INDEX_FILE" ]; then
    INDEX=$(cat "$INDEX_FILE")
else
    INDEX=0
fi

# Cambiar índice según argumento
case "$1" in
    next)
        INDEX=$((INDEX + 1))
        ;;
    prev)
        INDEX=$((INDEX - 1))
        ;;
    *)
        INDEX=$((INDEX + 1))
        ;;
esac

# Wrap
if [ "$INDEX" -ge "$TOTAL" ]; then
    INDEX=0
elif [ "$INDEX" -lt 0 ]; then
    INDEX=$((TOTAL - 1))
fi

# Guardar índice
echo "$INDEX" > "$INDEX_FILE"

NEW_WALL="${WALLS[$INDEX]}"

# Cursor global
POS=$(hyprctl cursorpos 2>/dev/null)
IFS=',' read -r X Y <<< "$POS"
X=$(echo "$X" | tr -d ' ')
Y=$(echo "$Y" | tr -d ' ')

# Monitor activo
read MON_NAME MON_X MON_Y MON_WIDTH MON_HEIGHT <<< $(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | "\(.name) \(.x) \(.y) \(.width) \(.height)"')

# Fallbacks
[ -z "$MON_WIDTH" ] && MON_WIDTH=1920
[ -z "$MON_HEIGHT" ] && MON_HEIGHT=1080
[ -z "$MON_X" ] && MON_X=0
[ -z "$MON_Y" ] && MON_Y=0

# Posición relativa
REL_X=$(awk "BEGIN {print $X - $MON_X}")
REL_Y=$(awk "BEGIN {print $Y - $MON_Y}")
REL_Y_INV=$(awk "BEGIN {print $MON_HEIGHT - $REL_Y}")

# Sanity
if [[ -z "$REL_X" || -z "$REL_Y_INV" ]]; then
    REL_X=$(awk "BEGIN {print $MON_WIDTH / 2}")
    REL_Y_INV=$(awk "BEGIN {print $MON_HEIGHT / 2}")
fi

# Aplicar wallpaper
awww img -o "$MON_NAME" "$NEW_WALL" \
    --transition-type grow \
    --transition-pos "$REL_X,$REL_Y_INV" \
    --transition-duration 1 \
    --transition-fps 60 \
    --resize fit
