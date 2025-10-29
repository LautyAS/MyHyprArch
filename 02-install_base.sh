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
parted -s "$DISK" mklabel gpt

# Crear partición EFI (512 MiB)
parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on

# Crear partición raíz (resto del disco)
parted -s "$DISK" mkpart primary ext4 513MiB 100%

# Asignar variables a particiones
EFI_PART="${DISK}1"
ROOT_PART="${DISK}2"

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
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# --- Instalación base ---
echo "📦 Instalando sistema base..."
pacstrap /mnt base base-devel linux linux-firmware linux-headers neovim sudo networkmanager grub efibootmgr git reflector

# --- fstab ---
echo "🗂️ Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# --- Crear swapfile ---
#echo "🧠 Creando swapfile de tamaño $SWAP_SIZE..."
#fallocate -l "$SWAP_SIZE" /mnt/swapfile
#chmod 600 /mnt/swapfile
#mkswap /mnt/swapfile
#swapon /mnt/swapfile
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
