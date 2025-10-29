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

#echo "💻 Instalando paru (AUR helper)..."
#cd /tmp
#git clone https://aur.archlinux.org/paru-bin.git
#cd paru-bin
#makepkg -si --noconfirm
#cd ..
#rm -rf paru-bin

echo "🎨 Instalando Hyprland, utilidades y floorp..."
pacman -S --noconfirm \
    hyprland hyprpaper kitty waybar wofi ly \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber lib32-pipewire pavucontrol \
    lib32-mesa mesa-utils vulkan-tools \
    fcitx5-im fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc \
    polkit polkit-gnome \
    nm-connection-editor \
    htop fastfetch \
    bash-completion \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    spotify-launcher steam \
    firefox \
    noto-fonts noto-fonts-cjk ttf-nerd-fonts-symbols ttf-noto-nerd ttf-firacode-nerd ttf-sourcecodepro-nerd ttf-jetbrains-mono ttf-roboto

echo "🔌 Habilitando servicios necesarios..."
systemctl enable NetworkManager
systemctl enable ly

echo "✅ Instalación de Hyprland y utilidades completada."
EOF
