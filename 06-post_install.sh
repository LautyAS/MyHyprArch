#!/bin/bash
set -e

echo "=== 06 - Post instalación y limpieza ==="
echo ""

# Montar /mnt si no lo estuviera
if [[ ! -d /mnt ]]; then
    echo "/mnt no está montado. Ejecuta primero los scripts anteriores."
    exit 1
fi

arch-chroot /mnt /bin/bash <<'EOF'
set -e

echo "Limpiando paquetes huérfanos..."
if pacman -Qtdq &>/dev/null; then
    pacman -Rns --noconfirm $(pacman -Qtdq)
else
    echo "No hay paquetes huérfanos."
fi

echo "Haciendo backups de archivos importantes..."
mkdir -p /root/install_backups
cp /etc/pacman.conf /root/install_backups/pacman.conf.bak
cp /etc/hostname /root/install_backups/hostname.bak
cp /etc/fstab /root/install_backups/fstab.bak

echo "Creando carpeta de wallpapers..."
mkdir -p /home/$USER/wallpapers
cp /usr/share/backgrounds/archlinux/default.jpg /home/$USER/wallpapers/arch_default.jpg || true
chown -R $USER:$USER /home/$USER/wallpapers

echo "Preparando dotfiles básicos..."
mkdir -p /home/$USER/.config/hypr
mkdir -p /home/$USER/.config/waybar
mkdir -p /home/$USER/.config/wofi

# Ejemplos de archivos vacíos o básicos
touch /home/$USER/.config/hypr/hyprland.conf
touch /home/$USER/.config/waybar/config
touch /home/$USER/.config/wofi/config

chown -R $USER:$USER /home/$USER/.config

echo "Post-instalación completada."
echo "El sistema está listo para reiniciar y comenzar a ricear Hyprland."
EOF
