#!/bin/bash
set -e

echo "=== 05 - Instalación de Hyprland y utilidades ==="
echo ""

# Montar /mnt si no lo estuviera
if [[ ! -d /mnt ]]; then
    echo "/mnt no está montado. Ejecuta primero los scripts anteriores."
    exit 1
fi

arch-chroot /mnt /bin/bash <<'EOF'
set -e

echo "Actualizando repositorios..."
pacman -Syu --noconfirm

echo "Instalando Hyprland y utilidades..."
pacman -S --noconfirm \
    hyprland \
    hyprpaper \
    kitty \
    firefox \
    waybar \
    wofi \
    pipewire pipewire-pulse pipewire-alsa \
    wireplumber \
    polkit polkit-gnome \
    nm-connection-editor \
    htop fastfetch \
    bash-completion \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    noto-fonts noto-fonts-cjk ttf-jetbrains-mono ttf-roboto \
    wofi rofi

# Habilitar servicios necesarios
systemctl enable NetworkManager

echo "Instalación de escritorio mínima completada."
EOF
