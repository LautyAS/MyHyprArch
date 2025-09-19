#!/bin/bash
set -e

echo "=== 07 - Aplicando configs y ricing ==="
echo ""

# Determinar usuario principal
USER=$(ls /mnt/home | head -n 1)
USER_HOME="/home/$USER"

# Directorios locales de tus configs y rice
CONFIGS_DIR="./configs"
RICE_DIR="./rice"

if [[ ! -d "$CONFIGS_DIR" ]]; then
    echo "No se encontró la carpeta configs."
    exit 1
fi

if [[ ! -d "$RICE_DIR" ]]; then
    echo "No se encontró la carpeta rice."
    exit 1
fi

arch-chroot /mnt /bin/bash <<EOF
set -e

USER_HOME="$USER_HOME"
CONFIGS_DIR="/mnt/$CONFIGS_DIR"
RICE_DIR="/mnt/$RICE_DIR"

echo "Copiando dotfiles desde configs..."
cp -r \$CONFIGS_DIR/* \$USER_HOME/.config/
echo "Copiadas configs principales."

echo "Aplicando rice adicional..."
for d in \$RICE_DIR/*; do
    if [[ -d "\$d" ]]; then
        cp -r \$d \$USER_HOME/.config/
        echo "Copiado \$(basename \$d) a .config"
    fi
done

chown -R $USER:$USER \$USER_HOME/.config

echo "Aplicando wallpaper..."
WALLPAPER_SRC="\$CONFIGS_DIR/wallpaper.jpg"
if [[ -f \$WALLPAPER_SRC ]]; then
    mkdir -p \$USER_HOME/wallpapers
    cp \$WALLPAPER_SRC \$USER_HOME/wallpapers/
    chown $USER:$USER \$USER_HOME/wallpapers/wallpaper.jpg
    # Ejecutar hyprpaper para fijarlo (se hace como el usuario)
    su - $USER -c "hyprpaper \$USER_HOME/wallpapers/wallpaper.jpg"
    echo "Wallpaper aplicado."
else
    echo "No se encontró wallpaper.jpg en configs."
fi

echo "Ricing completado. Puedes iniciar sesión y ver tu nuevo setup."
EOF

