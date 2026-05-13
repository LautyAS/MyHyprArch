#!/bin/bash
set -e

echo "=== 02 - Instalación base del sistema ==="
echo ""

# --- Comprobar variables ---
if [[ ! -f /tmp/install_vars.sh ]]; then
    echo "⚠️ No se encontró /tmp/install_vars.sh. Ejecuta primero 01-setup.sh"
    exit 1
fi
source /tmp/install_vars.sh

# Valor por defecto del swap si no está definido
SWAP_SIZE="${SWAP_SIZE:-4G}"

# --- Confirmar disco ---
read -rp "Esto borrará todo en $DISK. Continuar? [y/N]: " CONFIRM
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
parted -s "$DISK" mklabel gpt

# Crear partición EFI (512 MiB)
parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on

# Crear partición raíz (resto del disco)
parted -s "$DISK" mkpart primary ext4 513MiB 100%

# --- Detectar esquema de nombres de particiones ---
if [[ "$DISK" =~ [0-9]$ ]]; then
    PART_PREFIX="p"
else
    PART_PREFIX=""
fi

EFI_PART="${DISK}${PART_PREFIX}1"
ROOT_PART="${DISK}${PART_PREFIX}2"

# --- Formatear ---
echo "💾 Formateando particiones..."
mkfs.fat -F32 "$EFI_PART"
mkfs.ext4 -F "$ROOT_PART"

# --- Montar ---
echo "📂 Montando particiones..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

# Crear swapfile de 4G dentro de la raíz
SWAPFILE_SIZE=4G
echo "Creando swapfile de $SWAPFILE_SIZE..."
fallocate -l $SWAPFILE_SIZE /mnt/swapfile
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# --- Mirrors ---
echo "🌐 Actualizando mirrors más rápidos..."
pacman -Sy
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# --- Instalación base ---
echo "📦 Instalando sistema base..."
pacstrap /mnt base base-devel "$KERNEL_PKG" "$HEADERS_PKG" "$MICROCODE" linux-firmware $EXTRA_FW neovim sudo networkmanager grub efibootmgr git reflector

# --- fstab ---
echo "🗂️ Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab

# --- Variables ---
cp /tmp/install_vars.sh /mnt/tmp_install_vars.sh

# --- Mensaje final ---
cat <<EOF

✅ Instalación base completada correctamente.
El sistema está montado en /mnt e incluye un swapfile de $SWAP_SIZE.

👉 A continuación ejecuta dentro del live:
   ./03-config.sh
EOF
