#!/bin/bash
set -e

echo "=== 07 - Ricing inicial ==="
echo ""

# --- Detectar si estamos dentro del sistema o en el live ---
if [[ -d /mnt/root && "$(realpath /)" == "/" ]]; then
    echo "📦 Ejecutando dentro del live, entrando al chroot..."
    cp 07-ricing.sh /mnt/root/
    arch-chroot /mnt /bin/bash /root/07-ricing.sh
    exit 0
fi

# --- Levantar variables guardadas en instalación ---
if [[ -f /root/tmp_install_vars.sh ]]; then
    source /root/tmp_install_vars.sh
else
    echo "⚠️ No se encontró /root/tmp_install_vars.sh, usando USERNAME=usuario por defecto."
    USERNAME="usuario"
fi

# --- Verificar existencia del usuario ---
if ! id "$USERNAME" &>/dev/null; then
    echo "⚠️ El usuario '$USERNAME' no existe en el sistema."
    read -p "Ingrese el nombre del usuario que desea configurar: " USERNAME
    if ! id "$USERNAME" &>/dev/null; then
        echo "❌ El usuario '$USERNAME' sigue sin existir. Abortando."
        exit 1
    fi
fi

USER_HOME="/home/$USERNAME"

echo "🧑 Aplicando ricing para el usuario: $USERNAME"
echo ""

# --- Asegurar directorios ---
mkdir -p "$USER_HOME/.config" "$USER_HOME/Pictures/wallpapers"

# --- Copiar configuraciones ---

#echo "Se elimina posible configuracion corrupta de waybar"
#rm "@USER_HOME/.config/waybar/config"

echo "📁 Copiando configuraciones..."
if [[ -d /root/configs/.config ]]; then
    cp -r /root/configs/.config/* "$USER_HOME/.config/" 2>/dev/null || true
fi

if [[ -d /root/configs/etc/xdg ]]; then
    cp -r /root/configs/etc/xdg/* /etc/xdg/ 2>/dev/null || true
fi
#if [[ -d /root/configs/etx/xdg ]]; then
#    cp -r /root/configs/etc/xdg/* "$USER_HOME/.config" 2>/dev/null || true
#fi

# --- Copiar wallpapers ---
if [[ -d /root/rice/wallpapers ]]; then
    cp -r /root/rice/wallpapers/* "$USER_HOME/Pictures/wallpapers/"
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

# --- Permisos ---
#chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config" "$USER_HOME/Pictures"

echo ""
echo "✨ Ricing aplicado correctamente dentro del sistema."
