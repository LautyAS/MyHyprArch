#!/bin/bash
set -e

echo "=== 04 - Configuración del sistema ==="
echo ""

# Cargar elección de bootloader
if [[ -f /mnt/tmp_boot_choice.sh ]]; then
    source /mnt/tmp_boot_choice.sh
else
    echo "No se encontró la elección de bootloader. Usaremos systemd-boot por defecto."
    BOOTLOADER=systemd-boot
fi

# Chroot en /mnt para ejecutar comandos dentro del sistema
arch-chroot /mnt /bin/bash <<'EOF'
set -e

echo "Configurar hostname"
read -rp "Ingrese el hostname del sistema: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname

# Hosts básico
cat <<EOL > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOL

echo "Configurar usuario"
read -rp "Ingrese nombre de usuario: " USERNAME

# Contraseña del usuario
while true; do
    read -srp "Ingrese contraseña para $USERNAME: " USERPASS
    echo ""
    read -srp "Confirme contraseña: " USERPASS2
    echo ""
    [[ "$USERPASS" == "$USERPASS2" ]] && break
    echo "Las contraseñas no coinciden, intente de nuevo."
done

useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd

# Contraseña root
read -rp "¿Desea que root tenga la misma contraseña que $USERNAME? [y/N]: " SAMEPASS
case "$SAMEPASS" in
    [yY][eE][sS]|[yY])
        echo "root:$USERPASS" | chpasswd
        ;;
    *)
        while true; do
            read -srp "Ingrese contraseña para root: " ROOTPASS
            echo ""
            read -srp "Confirme contraseña root: " ROOTPASS2
            echo ""
            [[ "$ROOTPASS" == "$ROOTPASS2" ]] && break
            echo "Las contraseñas no coinciden, intente de nuevo."
        done
        echo "root:$ROOTPASS" | chpasswd
        ;;
esac

echo "Configurar locale"
echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Zona horaria
echo "Intentando detectar zona horaria..."
TZ=$(timedatectl list-timezones | grep -i "$(curl -s ifconfig.me)" | head -n 1 || true)
if [[ -z "$TZ" ]]; then
    echo "No se pudo detectar automáticamente la zona horaria."
    timedatectl list-timezones
    read -rp "Ingrese su zona horaria (ej: America/Argentina/Buenos_Aires): " TZ
fi
timedatectl set-timezone "$TZ"
timedatectl set-ntp true

echo "Activar NetworkManager"
systemctl enable NetworkManager

# Añadir swapfile al fstab
echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo "Instalando bootloader $BOOTLOADER..."
if [[ "$BOOTLOADER" == "systemd-boot" ]]; then
    bootctl --path=/boot install
    cat <<EOL > /boot/loader/loader.conf
default arch
timeout 3
editor 0
EOL

    ROOT_UUID=$(blkid -s UUID -o value /dev/disk/by-partuuid/$(lsblk -no PARTUUID $(findmnt / -n -o SOURCE)))
    cat <<EOL > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
EOL
else
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Configuración completa."
EOF
