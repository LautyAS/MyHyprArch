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

# Preguntar bootloader
echo ""
echo "Seleccione el bootloader a instalar:"
echo "1) systemd-boot (simple y transparente)"
echo "2) GRUB (dual-boot y más robusto)"
while true; do
    read -rp "Opción [1/2]: " BOOTCHOICE
    case "$BOOTCHOICE" in
        1)
            echo "systemd-boot seleccionado"
            echo "BOOTLOADER=systemd-boot" > /mnt/tmp_boot_choice.sh
            break
            ;;
        2)
            echo "GRUB seleccionado"
            echo "BOOTLOADER=grub" > /mnt/tmp_boot_choice.sh
            break
            ;;
        *)
            echo "Opción inválida, intenta de nuevo."
            ;;
    esac
done

echo "Instalación base completada."
echo "Ahora podes ejecutar el script 04-config_system.sh desde chroot."

