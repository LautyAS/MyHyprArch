#!/bin/bash

THEME=$1
HYPR="$HOME/.config/hypr"
QS="$HOME/.config/quickshell"
KITTY="$HOME/.config/kitty"

if [[ "$THEME" != "dark" && "$THEME" != "light" ]]; then
    echo "Usage: set-theme.sh dark|light"
    exit 1
fi

# ---------------- Hyprland ----------------
ln -sf "$HYPR/themes/$THEME.conf" "$HYPR/modules/theme.conf"

# ---------------- GTK ----------------
if [ "$THEME" = "dark" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme Kimi-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    kvantummanager --set Kimi-dark
else
    gsettings set org.gnome.desktop.interface gtk-theme Kimi
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    kvantummanager --set Kimi
fi

# ---------------- QT ----------------
qt6ct_conf="$HOME/.config/qt6ct/qt6ct.conf"
sed -i 's/^style=.*/style=Fusion/' "$qt6ct_conf"

# ---------------- Kitty ----------------
ln -sf "$KITTY/themes/$THEME.conf" "$KITTY/themes/current.conf"
pkill -USR1 kitty

# ---------------- Quickshell ----------------
ln -sf "$QS/colors/$THEME.json" "$QS/colors/current.json"
echo "$THEME" > "$QS/colors/.current_mode"

# ---------------- Reload Hyprland ----------------
hyprctl reload

# ---------------- Restart Quickshell ----------------
pkill qs
setsid qs >/dev/null 2>&1 &

notify-send "Theme" "Switched to $THEME theme"
