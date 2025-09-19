#!/bin/bash
set -e

# Cargar la variable del disco
source /tmp/install_disk.sh

echo "=== 02 - Formateo y montaje para UEFI ==="
echo ""

# Confirmación antes de borrar todo en el disco
read -rp "Esto borrará todo en $INSTALL_DISK. Continuar? [y/N]: " CONFIRM
case "$CONFIRM" in
    [yY][eE][sS]|[yY]) 
        echo "Procediendo con el formateo..."
        ;;
    *)
        echo "Abortando."
        exit 1
        ;;
esac

# Crear tabla de particiones GPT
parted -s "$INSTALL_DISK" mklabel gpt

# Crear partición EFI (512 MiB)
parted -s "$INSTALL_DISK" mkpart primary fat32 1MiB 513MiB
parted -s "$INSTALL_DISK" set 1 esp on

# Crear partición raíz (resto del disco)
parted -s "$INSTALL_DISK" mkpart primary ext4 513MiB 100%

# Asignar variables a particiones
EFI_PART="${INSTALL_DISK}1"
ROOT_PART="${INSTALL_DISK}2"

# Formatear particiones
mkfs.fat -F32 "$EFI_PART"
mkfs.ext4 -F "$ROOT_PART"

# Montar la raíz
mount "$ROOT_PART" /mnt

# Crear y montar la carpeta EFI
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

# Crear swapfile de 4G dentro de la raíz
SWAPFILE_SIZE=4G
echo "Creando swapfile de $SWAPFILE_SIZE..."
fallocate -l $SWAPFILE_SIZE /mnt/swapfile
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

echo "Formateo y montaje completados."
echo "Raíz: $ROOT_PART montada en /mnt"
echo "EFI: $EFI_PART montada en /mnt/boot/efi"
echo "Swapfile activo en /mnt/swapfile"
