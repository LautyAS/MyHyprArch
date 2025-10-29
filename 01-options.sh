#!/bin/bash
set -e

echo "=== 01 - Configuración inicial de instalación ==="
echo ""

# --- Verificar privilegios ---
if [[ $EUID -ne 0 ]]; then
    echo "⚠️  Este script debe ejecutarse como root."
    exit 1
fi

# --- Detección de fzf ---
USE_FZF=false
if command -v fzf >/dev/null 2>&1; then
    USE_FZF=true
fi

# --- Función auxiliar para selección ---
select_option() {
    local prompt="$1"; shift
    local options=("$@")

    if $USE_FZF; then
        echo "${options[@]}" | tr ' ' '\n' | fzf --prompt "$prompt → "
    else
        echo "$prompt"
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt"
            ((i++))
        done
        local choice
        while true; do
            read -rp "Selecciona una opción [1-${#options[@]}]: " choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#options[@]})); then
                echo "${options[$((choice - 1))]}"
                return
            else
                echo "❌ Opción inválida. Intenta de nuevo."
            fi
        done
    fi
}

# --- Selección de disco ---
echo ""
echo "Detectando discos disponibles..."
lsblk -dpno NAME,SIZE | grep -E "/dev/sd|/dev/nvme"
echo ""
read -rp "👉 Escribe el disco donde se instalará Arch (ej: /dev/sda, /dev/nvme0n1): " DISK

# --- Nombre de usuario ---
read -rp "👤 Ingresa el nombre de usuario: " USERNAME

# --- Nombre del host ---
read -rp "💻 Ingresa el nombre del equipo (hostname): " HOSTNAME

# --- Contraseña del usuario ---
read -rsp "🔑 Ingresa la contraseña del usuario: " PASSWORD
echo ""
read -rsp "🔑 Repite la contraseña: " PASSWORD2
echo ""
if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
    echo "❌ Las contraseñas no coinciden."
    exit 1
fi

# --- Zona horaria ---
#TIMEZONE_OPTIONS=("America/Argentina/Buenos_Aires" "America/Santiago" "America/Mexico_City" "Europe/Madrid" "UTC")
#TIMEZONE=$(select_option "🌎 Selecciona tu zona horaria" "${TIMEZONE_OPTIONS[@]}")

echo "Seleccione la zona horaria:"
TIMEZONE=$(find /usr/share/zoneinfo -type f \
    | sed 's|/usr/share/zoneinfo/||' \
    | fzf --prompt="Seleccione su zona horaria: " --height=40% --border --ansi)
echo "Zona horaria seleccionada: $TIMEZONE"


# --- Idioma del sistema ---
#LOCALE_OPTIONS=("es_AR.UTF-8" "es_ES.UTF-8" "en_US.UTF-8")
#LOCALE=$(select_option "🗣️  Selecciona el idioma del sistema" "${LOCALE_OPTIONS[@]}")

# --- GPU ---
#GPU_OPTIONS=("AMD" "Intel" "NVIDIA" "VM/Genérica (sin GPU dedicada)")
#GPU=$(select_option "🎮 Selecciona tu tipo de GPU" "${GPU_OPTIONS[@]}")


echo "Seleccione el fabricante de su GPU:"
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
read -rp "¿Confirmar y guardar configuración? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" ]]; then
    echo "Instalación cancelada."
    exit 0
fi

# --- Guardar variables ---
cat > /tmp/install_vars.sh <<EOF
DISK="$DISK"
USERNAME="$USERNAME"
HOSTNAME="$HOSTNAME"
PASSWORD="$PASSWORD"
TIMEZONE="$TIMEZONE"
LOCALE="$LOCALE"
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
