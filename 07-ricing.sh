#!/bin/bash
set -euo pipefail

# 07-ricing.sh
# Copia configs desde el repo a /mnt (chroot) y aplica ricing: /etc/xdg, ~/.config, wallpaper, fcitx5, etc.

echo "=== 07 - Ricing: aplicar configs (.config -> /home, etc/xdg -> /etc/xdg), wallpaper, fcitx5 ==="

# 1) Determinar repo y cómo referenciarlo desde dentro del chroot
REPO_HOST_PWD="$(pwd)"   # donde estás ejecutando este script
TMP_COPY_PATH="/mnt/.tmp_rice_repo"  # si tenemos que copiar dentro de /mnt
IN_CHROOT_REPO_PATH=""

if [[ "$REPO_HOST_PWD" == /mnt/* ]]; then
    # Si el repo está dentro de /mnt, dentro del chroot se accede sin el prefijo /mnt
    IN_CHROOT_REPO_PATH="${REPO_HOST_PWD#/mnt}"
else
    # Si el repo está en otra parte (p. ej. /root o /home del live), copiamos al /mnt temporalmente
    echo "Repositorio no está bajo /mnt; copiando temporalmente a $TMP_COPY_PATH ..."
    rm -rf "$TMP_COPY_PATH"
    mkdir -p "$TMP_COPY_PATH"
    cp -a "$REPO_HOST_PWD/"* "$TMP_COPY_PATH/"
    IN_CHROOT_REPO_PATH="${TMP_COPY_PATH#/mnt}"  # dentro del chroot será / .tmp_rice_repo
fi

echo "Usando path dentro del chroot: $IN_CHROOT_REPO_PATH"

# 2) Ejecutar acciones dentro del chroot
arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

REPO_PATH="$IN_CHROOT_REPO_PATH"
echo "Ejecutando dentro de chroot con repo en: \$REPO_PATH"

# Determinar usuario objetivo (primer folder en /home)
TARGET_USER="\$(ls /home | head -n 1)"
if [[ -z "\$TARGET_USER" ]]; then
    echo "No se encontró usuario en /home. Asegurate de haber creado el usuario en el paso 04."
    exit 1
fi
USER_HOME="/home/\$TARGET_USER"

echo "Usuario destino: \$TARGET_USER (home: \$USER_HOME)"

# Rutas en el repo
CONFIGS_DIR="\$REPO_PATH/configs"

# 2a) Copiar configs/.config --> /home/<user>/.config (si existe)
if [[ -d "\$CONFIGS_DIR/.config" ]]; then
    echo "Copiando \$CONFIGS_DIR/.config -> \$USER_HOME/.config ..."
    mkdir -p "\$USER_HOME/.config"
    cp -a "\$CONFIGS_DIR/.config/." "\$USER_HOME/.config/"
    chown -R \$TARGET_USER:\$TARGET_USER "\$USER_HOME/.config"
    echo "OK: configs de usuario aplicadas."
else
    echo "No existe \$CONFIGS_DIR/.config; salto copia a home."
fi

# 2b) Copiar configs/etc/xdg --> /etc/xdg (si existe) - archivos de sistema (root:root)
if [[ -d "\$CONFIGS_DIR/etc/xdg" ]]; then
    echo "Copiando \$CONFIGS_DIR/etc/xdg -> /etc/xdg ..."
    mkdir -p /etc/xdg
    cp -a "\$CONFIGS_DIR/etc/xdg/." /etc/xdg/
    # Asegurar root:root
    chown -R root:root /etc/xdg
    echo "OK: configs de /etc/xdg aplicadas."
else
    echo "No existe \$CONFIGS_DIR/etc/xdg; salto copia a /etc/xdg."
fi

# 2c) Aplicar wallpaper si hay uno en repo (prioridad: configs/wallpaper.jpg, luego .config/hypr/wallpaper.jpg)
WALLPAPER_SRC1="\$REPO_PATH/configs/wallpaper.jpg"
WALLPAPER_SRC2="\$REPO_PATH/configs/.config/hypr/wallpaper.jpg"
if [[ -f "\$WALLPAPER_SRC1" ]]; then
    WP_SRC="\$WALLPAPER_SRC1"
elif [[ -f "\$WALLPAPER_SRC2" ]]; then
    WP_SRC="\$WALLPAPER_SRC2"
else
    WP_SRC=""
fi

if [[ -n "\$WP_SRC" ]]; then
    echo "Aplicando wallpaper desde: \$WP_SRC"
    mkdir -p "\$USER_HOME/wallpapers"
    cp -a "\$WP_SRC" "\$USER_HOME/wallpapers/wallpaper.jpg"
    chown -R \$TARGET_USER:\$TARGET_USER "\$USER_HOME/wallpapers"
    # Ejecutar hyprpaper como usuario (si está instalado)
    if command -v hyprpaper &>/dev/null; then
        su - \$TARGET_USER -c "hyprpaper \$USER_HOME/wallpapers/wallpaper.jpg" || true
        echo "Hyprpaper intentó aplicar el wallpaper."
    else
        echo "hyprpaper no instalado en el chroot; wallpaper copiado a \$USER_HOME/wallpapers/wallpaper.jpg"
    fi
else
    echo "No se encontró wallpaper en repo."
fi

# 2d) Instalar fcitx5 + mozc y crear autostart en hypr
echo "Instalando fcitx5 y mozc..."
pacman -S --noconfirm --needed fcitx5 fcitx5-mozc fcitx5-configtool fcitx5-gtk fcitx5-qt || {
    echo "Error instalando paquetes de fcitx5. Continuo con el resto, pero revisalo."
}

# Crear archivo de autostart de hypr y agregar fcitx5 & si no está
AUTOSTART_FILE="\$USER_HOME/.config/hypr/autostart.conf"
mkdir -p "\$(dirname "\$AUTOSTART_FILE")"
touch "\$AUTOSTART_FILE"
chown -R \$TARGET_USER:\$TARGET_USER "\$USER_HOME/.config/hypr"

if ! grep -q "fcitx5" "\$AUTOSTART_FILE" 2>/dev/null; then
    echo "fcitx5 &" >> "\$AUTOSTART_FILE"
    chown \$TARGET_USER:\$TARGET_USER "\$AUTOSTART_FILE"
    echo "Se agregó 'fcitx5 &' a \$AUTOSTART_FILE"
else
    echo "fcitx5 ya estaba en \$AUTOSTART_FILE"
fi

# 2e) Variables de entorno para fcitx5 - /etc/profile.d (system-wide)
FCITX_PROFILE="/etc/profile.d/fcitx5.sh"
cat > "\$FCITX_PROFILE" <<'EOL'
# fcitx5 input method environment
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOL
chmod 644 "\$FCITX_PROFILE"
echo "Se creó \$FCITX_PROFILE para exportar GTK/Qt/XMODIFIERS."

# 2f) Mensaje final
echo "Ricing completado. Revisa:"
echo " - /etc/xdg (copiado desde configs/etc/xdg)"
echo " - \$USER_HOME/.config (copiado desde configs/.config)"
echo " - wallpaper en \$USER_HOME/wallpapers (si existía)"
echo " - fcitx5 instalado y añadido al autostart de Hyprland (si se pudo instalar pacman)."

EOF

# 3) Limpiar copia temporal si la hicimos
if [[ "$REPO_HOST_PWD" != /mnt/* ]]; then
    echo "Limpiando copia temporal en $TMP_COPY_PATH ..."
    rm -rf "$TMP_COPY_PATH"
fi

echo "=== 07 - Ricing finalizado ==="

