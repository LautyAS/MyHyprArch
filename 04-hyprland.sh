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
cd /home/$USERNAME
rm -rf paru-bin

echo "🎨 Instalando Hyprland, utilidades y floorp..."

packages=(hyprland hyprpaper kitty waybar wofi ly \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber lib32-pipewire pavucontrol \
    lib32-mesa mesa-utils vulkan-tools \
    fcitx5-im fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc \
    grim slurp swappy wl-clipboard \
    gvfs gvfs-mtp gvfs-afc gvfs-smb udiskie polkit thunar-volman \
    file-roller thunar-archive-plugin unzip p7zip unrar-free \
    polkit polkit-gnome \
    network-manager-applet \
    bluez bluez-utils blueman \
    htop fastfetch \
    bash-completion \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    spotify-launcher steam \
    imagemagick \
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-nerd-fonts-symbols ttf-noto-nerd ttf-firacode-nerd ttf-sourcecodepro-nerd ttf-jetbrains-mono ttf-roboto)

pacman -Syyu --noconfirm --needed "${packages[@]}"

su - "$USERNAME" -c "
cd /home/$USERNAME && \
git clone https://aur.archlinux.org/floorp-bin.git && \
cd floorp-bin && \
makepkg -f --noconfirm 
"

cd /home/$USERNAME/floorp-bin
for pkgfile in floorp-bin*.pkg.tar.zst; do
    pacman -U --noconfirm "$pkgfile"
done
cd /home/$USERNAME
rm -rf floorp-bin


echo "🔌 Habilitando servicios necesarios..."
systemctl enable bluetooth
systemctl enable NetworkManager
systemctl enable ly

echo "✅ Instalación de Hyprland y utilidades completada."
EOF
