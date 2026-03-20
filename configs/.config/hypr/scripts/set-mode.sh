#!/bin/bash

STATE_DIR="$HOME/.config/hypr/state"
THEME_DIR="$HOME/.config/hypr/themes"

MODE_FILE="$STATE_DIR/mode"
THEME_FILE="$STATE_DIR/theme"

THEME=$(cat "$THEME_FILE" 2>/dev/null)
MODE=$(cat "$MODE_FILE" 2>/dev/null)

# defaults seguros
[ -z "$THEME" ] && THEME="archxp"
[ -z "$MODE" ] && MODE="dark"

if [ "$1" == "toggle" ]; then
    if [ "$MODE" == "dark" ]; then
        NEW="light"
    else
        NEW="dark"
    fi
else
    NEW="$1"
fi

echo "$NEW" > "$MODE_FILE"

# aplicar correctamente
ln -sfn "$THEME_DIR/$THEME/$NEW.conf" "$THEME_DIR/$THEME/active.conf"
ln -sfn "$THEME_DIR/$THEME" "$THEME_DIR/current"

hyprctl reload
