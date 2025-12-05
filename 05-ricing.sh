#!/bin/bash
set -e

echo "=== 05 - Ricing ==="
echo ""

# --- Comprobar /mnt ---
if [[ ! -d /mnt ]]; then
    echo "⚠️ /mnt no está montado. Monta el sistema antes de continuar."
    exit 1
fi

cp -r configs/ /mnt/home
cp -r rice/ /mnt/home/rice

# --- Entrar al chroot ---
arch-chroot /mnt /bin/bash <<'EOF'
set -e

# --- Cargar variables ---
if [[ -f /tmp_install_vars.sh ]]; then
    source /tmp_install_vars.sh
else
    echo "⚠️ No se encontró /tmp_install_vars.sh dentro del chroot."
    exit 1
fi

USER_HOME="/home/$USERNAME"

echo "📂 Asegurando directorios del usuario..."
mkdir -p "$USER_HOME/.config"
mkdir -p "$USER_HOME/.themes"
mkdir -p "$USER_HOME/.icons"
mkdir -p "$USER_HOME/Pictures/wallpapers"
mkdir -p "$USER_HOME/Pictures/Screenshots"
mkdir -p "$USER_HOME/.config/dunst"

# --- Copiar configs ---
if [[ -d /home/configs/ ]]; then
    echo "📁 Copiando configuraciones de usuario..."
    cp -r /home/configs/* "$USER_HOME/"
fi

# --- Copiar wallpapers ---
if [[ -d /home/rice/wallpapers ]]; then
    cp -r /home/rice/wallpapers/* "$USER_HOME/Pictures/wallpapers/"
    echo "✅ Wallpapers copiados."
fi

# --- Fcitx5 autostart ---
AUTOSTART="$USER_HOME/.config/hypr/autostart.conf"
mkdir -p "$(dirname "$AUTOSTART")"
if ! grep -q "fcitx5" "$AUTOSTART" 2>/dev/null; then
    echo "fcitx5 &" >> "$AUTOSTART"
    echo "✅ Se agregó fcitx5 al autostart."
fi

# --- Permisos ---
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config" "$USER_HOME/Pictures"

echo "✨ Ricing aplicado correctamente dentro del chroot."

if [[ "$a11y" == "y" || "$a11y" == "Y" ]]; then
    systemctl --user mask at-spi-dbus-bus.service
fi


EOF
