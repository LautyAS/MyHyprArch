#!/bin/bash
set -e

echo "=== 07 - Aplicando configs y ricing ==="
echo ""

# Determinar usuario principal
USER=$(ls /mnt/home | head -n 1)
USER_HOME="/mnt/home/$USER"

# Directorios locales de tus configs y rice (desde donde ejecutás el script)
CONFIGS_DIR="./configs"
RICE_DIR="./rice"

# Comprobar existencia de carpetas
if [[ ! -d "$CONFIGS_DIR" ]]; then
    echo "No se encontró la carpeta configs."
    exit 1
fi

if [[ ! -d "$RICE_DIR" ]]; then
    echo "No se encontró la carpeta rice."
    exit 1
fi

# Crear .config en el sistema instalado
mkdir -p "$USER_HOME/.config"

echo "Copiando dotfiles desde configs..."
cp -r "$CONFIGS_DIR/"* "$USER_HOME/.config/"
echo "Copiadas configs principales."

echo "Aplicando rice adicional..."
for d in "$RICE_DIR/"*; do
    if [[ -d "$d" ]]; then
        cp -r "$d" "$USER_HOME/.config/"
        echo "Copiado $(basename "$d") a .config"
    fi
done

# Ajustar permisos
arch-chroot /mnt /bin/bash <<EOF
chown -R $USER:$USER /home/$USER/.config
if [[ -d /home/$USER/wallpapers ]]; then
    chown -R $USER:$USER /home/$USER/wallpapers
fi
EOF

# Aplicar wallpaper si existe
WALLPAPER_SRC="$CONFIGS_DIR/wallpaper.jpg"
if [[ -f "$WALLPAPER_SRC" ]]; then
    mkdir -p "$USER_HOME/wallpapers"
    cp "$WALLPAPER_SRC" "$USER_HOME/wallpapers/"
    chown $USER:$USER "$USER_HOME/wallpapers/wallpaper.jpg"
    echo "Wallpaper copiado. Se aplicará al iniciar sesión."
else
    echo "No se encontró wallpaper.jpg en configs."
fi

echo "Ricing completado. Puedes iniciar sesión y ver tu nuevo setup."

