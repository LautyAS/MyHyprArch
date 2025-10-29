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

echo ""
echo "=== Configuración de zona horaria ==="

# Instalar fzf si no está disponible
if ! command -v fzf &>/dev/null; then
    echo "Instalando fzf..."
    pacman -Sy --noconfirm fzf
fi

echo ""
echo "🕓 Selección de zona horaria"
echo "Usa ↑ ↓ para moverte, escribe para filtrar, y presiona Enter para seleccionar."
sleep 2

timezone=$(find /usr/share/zoneinfo -type f | sed 's|/usr/share/zoneinfo/||' | fzf --prompt="Seleccione su zona horaria: " --height=40% --border --ansi)

if [[ -n "$timezone" ]]; then
    ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
    hwclock --systohc
    echo "Zona horaria configurada en: $timezone"
else
    echo "No se seleccionó ninguna zona horaria, se usará UTC por defecto."
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    hwclock --systohc
fi

echo ""
echo "=== Actualizando repositorios ==="
pacman -Syu git base-devel archlinux-keyring --noconfirm

echo ""
echo "=== Selección interactiva de GPU ==="

# Verificar fzf otra vez dentro del entorno chroot
if ! command -v fzf &>/dev/null; then
    echo "Instalando fzf..."
    pacman -Sy --noconfirm fzf
fi

echo ""
echo "🎮 Selección de controladores gráficos"
echo "Usa ↑ ↓ para moverte, escribe para filtrar, y presiona Enter para seleccionar."
sleep 2

gpu_choice=$(printf "AMD\nIntel\nNVIDIA\nOmitir" | fzf --prompt="Seleccione el fabricante de su GPU: " --height=40% --border --ansi)

case "$gpu_choice" in
    "AMD")
        echo "→ Instalando controladores AMD..."
        pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon
        ;;
    "Intel")
        echo "→ Instalando controladores Intel..."
        pacman -S --noconfirm vulkan-intel lib32-vulkan-intel intel-media-driver
        ;;
    "NVIDIA")
        echo "→ Instalando controladores NVIDIA..."
        pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
        ;;
    "Omitir"|*)
        echo "→ Omitiendo instalación de drivers de GPU."
        ;;
esac

echo ""
echo "=== Instalando Hyprland y utilidades ==="

pacman -S --noconfirm \
    hyprland hyprpaper kitty waybar wofi ly \
    firefox \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber lib32-pipewire pavucontrol \
    lib32-mesa mesa-utils vulkan-tools \
    fcitx5-im fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc \
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

echo ""
echo "Instalación de escritorio mínima completada."
EOF
