#!/bin/bash
set -e

echo "=== 04 - Instalación de Hyprland y utilidades ==="
echo ""

# --- Comprobar /mnt ---
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

echo "📦 Actualizando sistema..."
pacman -Syu --noconfirm git base-devel

echo "💻 Instalando paru (AUR helper)..."
su - "$USERNAME" -c "
cd /home/$USERNAME && \
git clone https://aur.archlinux.org/paru-bin.git && \
cd paru-bin && \
makepkg -f --noconfirm 
"

cd /home/$USERNAME/paru-bin
for pkgfile in paru-bin*.pkg.tar.zst; do
    pacman -U --noconfirm "$pkgfile"
done
cd /home/$USERHOME
rm -rf paru-bin


echo "Dando permisos de ejecución de paru sin contraseña..."

echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/paru, /usr/bin/pacman" | sudo tee /etc/sudoers.d/paru > /dev/null
sudo chmod 440 /etc/sudoers.d/paru

echo "🎨 Instalando Hyprland, utilidades y floorp..."

packages = (
    hyprland hyprpaper kitty waybar wofi ly
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber lib32-pipewire pavucontrol
    lib32-mesa mesa-utils vulkan-tools
    fcitx5-im fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc
    polkit polkit-gnome
    nmcli nm-applet
    htop fastfetch
    bash-completion
    xdg-desktop-portal xdg-desktop-portal-wlr
    spotify-launcher steam
    floorp-bin
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-nerd-fonts-symbols ttf-noto-nerd ttf-firacode-nerd ttf-sourcecodepro-nerd ttf-jetbrains-mono ttf-roboto
    )

su - "$USERNAME" -c "paru -S --noconfirm ${packages[@]}"

echo "🔌 Habilitando servicios necesarios..."
systemctl enable NetworkManager
systemctl enable ly

echo "✅ Instalación de Hyprland y utilidades completada."
EOF
