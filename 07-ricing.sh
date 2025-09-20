#!/bin/bash
set -e

echo "=== 07 - Aplicando configs y ricing ==="
echo ""

# Determinar usuario principal
USER=$(ls /mnt/home | head -n 1)
USER_HOME="/mnt/home/$USER"

# Directorios locales de tus configs y rice (desde donde ejecutás el script)
CONFIGS_DIR="./configs/.config"

# Crear .config en el sistema instalado
mkdir -p "$USER_HOME/.config"
mkdir -p /mnt/etc/

echo "Copiando dotfiles desde configs..."
cp -r "$CONFIGS_DIR/"* "$USER_HOME/.config/"
cp -r "./configs/etc"* "/mnt/etc"
echo "Copiadas configs principales."

# Ajustar permisos dentro del chroot (ahí sí existe el usuario)
arch-chroot /mnt /bin/bash <<EOF
chown -R $USER:$USER /home/$USER/.config
if [[ -d /home/$USER/wallpapers ]]; then
    chown -R $USER:$USER /home/$USER/wallpapers
fi
EOF

echo "Ricing completado. Puedes iniciar sesión y ver tu nuevo setup."

