#!/bin/bash
set -e

echo "=== 07 - Ricing inicial ==="
echo ""

# Levantar variables guardadas
if [[ -f /mnt/tmp_install_vars.sh ]]; then
    source /mnt/tmp_install_vars.sh
else
    echo "⚠️ No se encontró /mnt/tmp_install_vars.sh, usando USERNAME=usuario por defecto."
    USERNAME="usuario"
fi

USER_HOME="/mnt/home/$USERNAME"

# Crear directorios de usuario
mkdir -p "$USER_HOME/.config" "$USER_HOME/Pictures/wallpapers"

# --- Copiar configuraciones del usuario ---
echo "Copiando configuraciones personales..."
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
fi

# --- Aplicar configuraciones globales dentro del chroot ---
arch-chroot /mnt /bin/bash <<EOF
set -e
echo "Aplicando configuraciones globales (xdg, etc)..."

# Copiar configuraciones de /etc/xdg
if [[ -d /configs/etc/xdg ]]; then
    cp -r /configs/etc/xdg/* /etc/xdg/
    echo "✅ Configs globales copiadas."
else
    echo "⚠️ No se encontró /configs/etc/xdg dentro del chroot."
fi

# Asegurar permisos de usuario
if id "$USERNAME" &>/dev/null; then
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config" "/home/$USERNAME/Pictures"
    echo "✅ Permisos corregidos para $USERNAME."
else
    echo "⚠️ Usuario $USERNAME no encontrado en el sistema, se omitió el chown."
fi
EOF

echo "✨ Ricing aplicado correctamente."

