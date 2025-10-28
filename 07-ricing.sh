#!/bin/bash
set -e

echo "=== 07 - Ricing inicial ==="
echo ""

# Levantar variables guardadas en instalación
if [[ -f /mnt/tmp_install_vars.sh ]]; then
    source /mnt/tmp_install_vars.sh
else
    echo "⚠️ No se encontró /mnt/tmp_install_vars.sh, usando USERNAME=usuario por defecto."
    USERNAME="usuario"
fi

USER_HOME="/mnt/home/$USERNAME"

# Asegurar directorios
mkdir -p "$USER_HOME/.config" "$USER_HOME/Pictures/wallpapers"

# --- Copiar configuraciones ---
echo "Copiando configuraciones de usuario..."
cp -r configs/.config/* "$USER_HOME/.config/" 2>/dev/null || true

# --- Copiar wallpapers ---
if [[ -d rice/wallpapers ]]; then
    cp -r rice/wallpapers/* "$USER_HOME/Pictures/wallpapers/"
    echo "✅ Wallpapers copiados."
else
    echo "⚠️ No se encontró la carpeta rice/wallpapers."
fi

# --- Fcitx5 autostart ---
AUTOSTART="$USER_HOME/.config/hypr/autostart.conf"
mkdir -p "$(dirname "$AUTOSTART")"

if ! grep -q "fcitx5" "$AUTOSTART" 2>/dev/null; then
    echo "fcitx5 &" >> "$AUTOSTART"
    echo "✅ Se agregó fcitx5 al autostart."
else
    echo "⚠️ fcitx5 ya estaba en $AUTOSTART."
fi

echo "✨ Ricing aplicado (desde live)."
