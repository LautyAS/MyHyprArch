#!/bin/bash
set -e

echo "=== 04 - Configuración del sistema ==="
echo ""

# Cargar disco elegido en 01-check_disk.sh
if [[ -f /tmp/install_disk.sh ]]; then
    source /tmp/install_disk.sh
else
    echo "No se encontró el archivo /tmp/install_disk.sh. Ejecuta primero 01-check_disk.sh"
    exit 1
fi

# ---- Solicitar usuario y contraseñas fuera del chroot ----
read -rp "Ingrese el hostname del sistema: " HOSTNAME
read -rp "Ingrese nombre de usuario: " USERNAME
echo "USERNAME=$USERNAME" > /mnt/tmp_install_vars.sh

# Contraseña del usuario
while true; do
    read -srp "Ingrese contraseña para $USERNAME: " USERPASS
    echo ""
    read -srp "Confirme contraseña: " USERPASS2
    echo ""
    [[ "$USERPASS" == "$USERPASS2" ]] && break
    echo "Las contraseñas no coinciden, intente de nuevo."
done

# Contraseña root
read -rp "¿Desea que root tenga la misma contraseña que $USERNAME? [y/N]: " SAMEPASS
case "$SAMEPASS" in
    [yY][eE][sS]|[yY])
        ROOTPASS="$USERPASS"
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
        ;;
esac

# ---- Ejecutar chroot ----
arch-chroot /mnt /bin/bash <<EOF
set -e

INSTALL_DISK="$INSTALL_DISK"

# Configurar hostname
echo "$HOSTNAME" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOL

# Crear usuario y root
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd
echo "Usuario $USERNAME creado."

echo "root:$ROOTPASS" | chpasswd
echo "Contraseña de root configurada."

# Configurar sudo para el grupo wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Configurar locale
sed -i 's/^#\(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Zona horaria
echo "Intentando detectar zona horaria..."
timedatectl list-timezones | grep -q "America/Argentina/Buenos_Aires" && TZ="America/Argentina/Buenos_Aires" || TZ="UTC"
timedatectl set-timezone "\$TZ"
timedatectl set-ntp true

# Habilitar NetworkManager
systemctl enable NetworkManager

# Añadir swapfile al fstab
echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Instalar bootloader
echo "Instalando bootloader GRUB..."
    pacman -S --noconfirm grub
    if [[ -d /sys/firmware/efi ]]; then
        echo "UEFI detectado → instalando GRUB en EFI..."
        pacman -S --noconfirm efibootmgr
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    else
        echo "BIOS detectado → instalando GRUB en MBR de \$INSTALL_DISK..."
        grub-install --target=i386-pc "\$INSTALL_DISK"
    fi
    grub-mkconfig -o /boot/grub/grub.cfg

EOF

echo "Configuración completa. Ahora podés continuar con el script 05-install_desktop.sh."
