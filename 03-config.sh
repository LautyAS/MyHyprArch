#!/bin/bash
set -e

echo "=== 03 - Configuración del sistema base ==="
echo ""

# --- Verificar /mnt ---
if [[ ! -d /mnt ]]; then
    echo "⚠️ /mnt no está montado. Monta el sistema antes de continuar."
    exit 1
fi

# --- Entrar al chroot ---
arch-chroot /mnt /bin/bash <<'EOF'
set -e

# --- Cargar variables ---
if [[ -f /tmp_install_vars.sh ]]; then
    source /tmp_install_vars.sh
else
    echo "⚠️ No se encontró /tmp_install_vars.sh dentro del chroot."
    exit 1
fi

echo "🔧 Configurando hostname..."
echo "$HOSTNAME" > /etc/hostname
cat <<HOSTS_EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF

echo "🌎 Configurando zona horaria..."
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

echo "🗣️ Configurando locale..."
if ! grep -q "^$LOCALE" /etc/locale.gen; then
    echo "$LOCALE UTF-8" >> /etc/locale.gen
fi
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

echo "👤 Creando usuario y configurando sudo..."
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "🔌 Habilitando NetworkManager..."
systemctl enable NetworkManager

echo "🎮 Instalando paquetes específicos para GPU..."
case "$GPU" in
    AMD)
        pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon
        ;;
    Intel)
        pacman -S --noconfirm vulkan-intel lib32-vulkan-intel intel-media-driver
        ;;
    NVIDIA)
        pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
        ;;
    *)
        echo "❌ Omitiendo instalación de drivers GPU específicos"
        ;;
esac

echo "✅ Configuración del sistema base completada."
echo "💡 Próximo paso: ejecutar los scripts de rice y personalización del usuario."
EOF
