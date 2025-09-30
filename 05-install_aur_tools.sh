#!/bin/bash
set -e

echo "=== 05 - Instalación de Hyprland y utilidades ==="
echo ""

# Montar /mnt si no lo estuviera
if [[ ! -d /mnt ]]; then
    echo "/mnt no está montado. Ejecuta primero los scripts anteriores."
    exit 1
fi

echo "Haciendo backup de la configuración de pacman..."
CONFPM="/mnt/etc/pacman.conf"
cp "$CONFPM" "${CONFPM}.bak"

echo "Configurando pacman..."
grep -q "^ILoveCandy" "$CONFPM" || sed -i '/#Color/i ILoveCandy' "$CONFPM"
sed -i 's/^#Color/Color/' "$CONFPM"
sed -i 's/^#\?\s*ParallelDownloads *= *.*/ParallelDownloads = 10/' "$CONFPM"
sed -i '/^\s*#\[multilib\]/s/^#//' "$CONFPM"
sed -i '/^\[multilib\]/,/^$/s/^\(\s*\)#\s*\(Include = \/etc\/pacman.d\/mirrorlist\)/\1\2/' "$CONFPM"

arch-chroot /mnt /bin/bash <<'EOF'
set -e

echo "Actualizando repositorios..."
pacman -Syu git base-devel --needed --noconfirm

echo "instalando paru aur helper..."

#git clone https://aur.archlinux.org/paru-bin.git
#cd paru-bin
#makepkg -si --noconfirm
#cd ..
#rm -rf paru-bin

echo -e "Instalación de controladores gráficos...\n"

echo -e "Seleccione el fabricante de su GPU:\n"
echo "1) AMD"
echo "2) Intel"
echo "3) NVidia"
echo "4) (Ya lo manejaré yo) (Esta opción por lo general instala amkvlk como predeterminado)"
read -p "Vendedor: " gpu_choice

case "$gpu_choice" in
1)
		echo "--> AMD Selected"
		pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon
		;;
2)
		echo "--> Intel Selected"
		pacman -S --noconfirm vulkan-intel lib32-vulkan-intel intel-media-driver
		;;
3)
		echo "--> Nvidia Selected"
		pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
		;;
*)
		echo "--> Omitiendo instalación de drivers de GPU específicos"
		;;
esac

echo "Instalando Hyprland y utilidades..."
pacman -S --noconfirm \
    hyprland hyprpaper kitty waybar wofi ly \
    firefox \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber lib32-pipewire pavucontrol \
    lib32-mesa mesa-utils vulkan-tools \
    polkit polkit-gnome \
    nm-connection-editor \
    htop fastfetch \
    bash-completion \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    spotify-launcher steam \
    noto-fonts noto-fonts-cjk ttf-nerd-fonts-symbols ttf-noto-nerd ttf-firacode-nerd ttf-sourcecodepro-nerd ttf-jetbrains-mono ttf-roboto 

# Habilitar servicios necesarios
systemctl enable NetworkManager
systemctl enable ly

echo "Instalación de escritorio mínima completada."
EOF
