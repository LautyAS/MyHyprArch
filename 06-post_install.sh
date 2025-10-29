#!/bin/bash
set -e

echo "=== 06 - Post instalación y limpieza ==="
echo ""

# Verificar que /mnt esté montado
if [[ ! -d /mnt ]]; then
    echo "/mnt no está montado. Ejecuta primero los scripts anteriores."
    exit 1
fi

# Copiar configs y rice al nuevo sistema (para que estén disponibles en el chroot)
if [[ -d configs ]]; then
    cp -r configs /mnt/root/
    echo "✅ Copiada carpeta configs al sistema nuevo."
else
    echo "⚠️ No se encontró carpeta configs."
fi

if [[ -d rice ]]; then
    cp -r rice /mnt/root/
    echo "✅ Copiada carpeta rice al sistema nuevo."
else
    echo "⚠️ No se encontró carpeta rice."
fi

# Entrar al nuevo sistema y hacer limpieza y preparativos
arch-chroot /mnt /bin/bash <<EOF
set -e

echo "Limpiando paquetes huérfanos..."
if pacman -Qtdq &>/dev/null; then
    pacman -Rns --noconfirm \$(pacman -Qtdq)
else
    echo "No hay paquetes huérfanos."
fi

echo "Haciendo backups de archivos importantes..."
mkdir -p /root/install_backups
cp /etc/pacman.conf /root/install_backups/pacman.conf.bak
cp /etc/hostname /root/install_backups/hostname.bak
cp /etc/fstab /root/install_backups/fstab.bak

# Obtener nombre de usuario (por si hace falta)
USERNAME=\$(ls /home | head -n 1)
if [[ -z "\$USERNAME" ]]; then
    echo "⚠️ No se encontró usuario en /home, usando 'usuario'."
    USERNAME="usuario"
fi

echo "Creando carpeta de wallpapers..."
mkdir -p /home/\$USERNAME/wallpapers
cp /usr/share/backgrounds/archlinux/default.jpg /home/\$USERNAME/wallpapers/arch_default.jpg || true
chown -R \$USERNAME:\$USERNAME /home/\$USERNAME/wallpapers

echo "Preparando dotfiles básicos..."
mkdir -p /home/\$USERNAME/.config/hypr
mkdir -p /home/\$USERNAME/.config/waybar
mkdir -p /home/\$USERNAME/.config/wofi

# Archivos vacíos por defecto
touch /home/\$USERNAME/.config/hypr/hyprland.conf
touch /home/\$USERNAME/.config/waybar/config
touch /home/\$USERNAME/.config/wofi/config

chown -R \$USERNAME:\$USERNAME /home/\$USERNAME/.config

echo ""
echo "✅ Post-instalación completada. Puedes ejecutar 07-ricing.sh dentro del chroot."
EOF
