#!/bin/bash
set -e

echo "=== 07 - Ricing inicial (modo chroot-safe) ==="
echo ""

# --- Levantar variables ---
if [[ -f /mnt/tmp_install_vars.sh ]]; then
    source /mnt/tmp_install_vars.sh
else
    echo "⚠️ No se encontró /mnt/tmp_install_vars.sh, usando USERNAME=usuario por defecto."
    USERNAME="usuario"
fi

USER_HOME="/mnt/home/$USERNAME"

# --- Copiar configs al sistema instalado ---
echo "Preparando archivos para copiar dentro del chroot..."
mkdir -p /mnt/root/configs-temp
cp -r configs/* /mnt/root/configs-temp/
echo "✅ Archivos copiados temporalmente en /root/configs-temp."

# --- Entrar al chroot y aplicar ricing ---
arch-chroot /mnt /bin/bash <<EOF
set -e
echo ""
echo "Aplicando ricing dentro del sistema instalado..."
echo ""

USER_HOME="/home/$USERNAME"

# Crear carpetas si no existen
mkdir -p "\$USER_HOME/.config" "\$USER_HOME/Pictures/wallpapers"

# --- Copiar configuraciones ---
echo "Copiando configuraciones de usuario..."
cp -r /root/configs-temp/.config/* "\$USER_HOME/.config/" 2>/dev/null || true

# --- Copiar configuraciones globales ---
if [[ -d /root/configs-temp/etc/xdg ]]; then
    cp -r /root/configs-temp/etc/xdg/* /etc/xdg/
    echo "✅ Configuraciones globales copiadas."
fi

# --- Copiar wallpapers ---
if [[ -d /root/configs-temp/rice/wallpapers ]]; then
    cp -r /root/configs-temp/rice/wallpapers/* "\$USER_HOME/Pictures/wallpapers/"
    echo "✅ Wallpapers copiados."
else
    echo "⚠️ No se encontró /root/configs-temp/rice/wallpapers."
fi

# --- Fcitx5 autostart ---
AUTOSTART="\$USER_HOME/.config/hypr/autostart.conf"
mkdir -p "\$(dirname "\$AUTOSTART")"
if ! grep -q "fcitx5" "\$AUTOSTART" 2>/dev/null; then
    echo "fcitx5 &" >> "\$AUTOSTART"
    echo "✅ Se agregó fcitx5 al autostart."
fi

# --- Permisos ---
if id "$USERNAME" &>/dev/null; then
    chown -R "$USERNAME:$USERNAME" "\$USER_HOME/.config" "\$USER_HOME/Pictures"
    echo "✅ Permisos corregidos para $USERNAME."
else
    echo "⚠️ Usuario $USERNAME no encontrado, se omitió el chown."
fi

# --- Limpiar temporal ---
rm -rf /root/configs-temp
echo "🧹 Limpieza completada."

echo "✨ Ricing aplicado exitosamente dentro del chroot."
EOF

echo ""
echo "✅ Ricing finalizado. El keyring no debería verse afectado."
