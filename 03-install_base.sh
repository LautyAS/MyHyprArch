#!/bin/bash
set -e

echo "=== 03 - Instalación del sistema base ==="
echo ""

# Montaje ya debería estar hecho por el script anterior
if [[ ! -d /mnt ]]; then
    echo "/mnt no está montado. Ejecuta primero 02-format_mount.sh"
    exit 1
fi

# Paquetes base esenciales
echo "Instalando base, linux, linux-firmware, sof-firmware, neovim, sudo, git, networkmanager, base-devel..."
pacstrap /mnt base linux linux-firmware sof-firmware neovim sudo git networkmanager base-devel

# Generar fstab
echo "Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# bootloader
echo "BOOTLOADER=grub" > /mnt/tmp_boot_choice.sh

echo ""
echo "Instalación base completada."
echo "Ahora podés ejecutar el script 04-config_system.sh desde chroot."

