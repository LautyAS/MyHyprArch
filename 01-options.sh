#!/bin/bash
set -e

echo "=== 01 - Configuración inicial de instalación ==="
echo ""

# --- Verificar privilegios ---
if [[ $EUID -ne 0 ]]; then
    echo "⚠️  Este script debe ejecutarse como root."
    exit 1
fi

echo "Instalando fzf para seleccionar configs"

pacman -S --noconfirm --needed fzf

# --- Detección de fzf ---
USE_FZF=false
if command -v fzf >/dev/null 2>&1; then
    USE_FZF=true
fi

# --- Función auxiliar para selección ---
select_option() {
    local prompt="$1"; shift
    local options=("$@")

    #if $USE_FZF; then
        echo "${options[@]}" | tr ' ' '\n' | fzf --prompt "$prompt → "
    #else
    #    echo "$prompt"
    #    local i=1
    #    for opt in "${options[@]}"; do
    #        echo "  $i) $opt"
    #        ((i++))
    #    done
    #    local choice
    #    while true; do
    #        read -rp "Selecciona una opción [1-${#options[@]}]: " choice
    #        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#options[@]})); then
    #            echo "${options[$((choice - 1))]}"
    #            return
    #        else
    #            echo "❌ Opción inválida. Intenta de nuevo."
    #        fi
    #    done
    #fi
}

# --- Selección de disco ---
echo ""
echo "Detectando discos disponibles..."
lsblk -dpno NAME,SIZE | grep -E "/dev/sd|/dev/nvme"
echo ""
read -rp "👉 Escribe el disco donde se instalará Arch (ej: /dev/sda, /dev/nvme0n1): " DISK

# --- Nombre del host ---
read -rp "💻 Ingresa el nombre del equipo (hostname): " HOSTNAME

# --- Nombre de usuario ---
read -rp "👤 Ingresa el nombre de usuario: " USERNAME

# --- Contraseña del usuario ---
read -rsp "🔑 Ingresa la contraseña del usuario: " PASSWORD
echo ""
read -rsp "🔑 Repite la contraseña: " PASSWORD2
echo ""
if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
    echo "❌ Las contraseñas no coinciden."
    exit 1
fi

# --- Contraseña root ---
read -rp "    ¿Desea que root tenga la misma contraseña que $USERNAME? [y/N]: " SAMEPASS
case "$SAMEPASS" in
    [yY][eE][sS]|[yY])
        ROOTPASS="$USERPASS"
        ;;
    *)
        while true; do
            read -srp "Ingrese contraseña para root: " ROOTPASS
            echo ""
            read -srp "Confirme contraseña root: " ROOTPASS2
            echo ""
            [[ "$ROOTPASS" == "$ROOTPASS2" ]] && break
            echo "Las contraseñas no coinciden, intente de nuevo."
        done
        ;;
esac

# --- Servicio de accesibilidad ---
read -p "¿Querés desactivar (at-spi-dbus-bus) para ahorrar algunos recursos? (Es un servicio de accesibilidad, la mayoría de la gente no lo necesita) (y/N): " a11y

# --- Impresoras ---
read -p "¿Querés instalar servicios de impresoras? (y/N): " PRINTSRV

echo "Seleccione la zona horaria:"
TIMEZONE=$(find /usr/share/zoneinfo -type f \
    | sed 's|/usr/share/zoneinfo/||' \
    | fzf --prompt="Seleccione su zona horaria: " --height=40% --border --ansi)
echo "Zona horaria seleccionada: $TIMEZONE"

# --- Idioma del sistema ---
LOCALE_OPTIONS=("es_AR.UTF-8" "es_ES.UTF-8" "en_US.UTF-8")
LOCALE=$(select_option "🗣️  Selecciona el idioma del sistema" "${LOCALE_OPTIONS[@]}")

# --- GPU ---
GPU=$(printf "AMD\nIntel\nNvidia\nOmitir\n" | fzf --height=10 --border --prompt="GPU: ")
echo "GPU seleccionado: $GPU"

# --- Confirmación ---
echo ""
echo "Resumen de configuración:"
echo "  Disco:          $DISK"
echo "  Usuario:        $USERNAME"
echo "  Hostname:       $HOSTNAME"
echo "  Zona horaria:   $TIMEZONE"
echo "  Locale:         $LOCALE"
echo "  GPU:            $GPU"

echo ""
read -rp "¿Confirmar y guardar configuración? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" || "$CONFIRM" == "Y" ]]; then
    echo "Instalación cancelada."
    exit 0
fi

# --- Guardar variables ---
cat > /tmp/install_vars.sh <<EOF
DISK="$DISK"
USERNAME="$USERNAME"
HOSTNAME="$HOSTNAME"
PASSWORD="$PASSWORD"
ROOTPASS="$ROOTPASS"
TIMEZONE="$TIMEZONE"
LOCALE="$LOCALE"
PRINTSRV="$PRINTSRV"
a11y="$a11y"
GPU="$GPU"
EOF

# --- Si ya existe /mnt (para cuando se corre desde el live antes del chroot) ---
if [[ -d /mnt ]]; then
    cp /tmp/install_vars.sh /mnt/tmp_install_vars.sh 2>/dev/null || true
fi

echo "✅ Configuración guardada en /tmp/install_vars.sh"
if $USE_FZF; then
    echo "✨ Menús mostrados con fzf (más bonito y rápido)."
else
    echo "✨ Menús mostrados con select (fzf no encontrado)."
fi
echo "👉 Los próximos scripts usarán esta configuración automáticamente."
