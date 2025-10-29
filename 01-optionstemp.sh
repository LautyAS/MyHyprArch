#!/bin/bash
set -e

echo "=== 01-options.sh: Configuración inicial interactiva ==="

# --- Función de selección con fzf ---
select_fzf() {
    echo "$1" | fzf --height 15 --prompt="$2: "
}

# --- Selección de disco ---
echo "Seleccione el disco para la instalación:"
DISK=$(lsblk -d -o NAME,SIZE,MODEL | grep -v "loop" | awk '{print "/dev/" $1 " (" $2 ", " $3 ")"}' | fzf --height 10 --prompt="Disco: ")
# Extraer solo el nombre del disco
DISK=$(echo "$DISK" | awk -F'[ /()]+' '{print $2}')
DISK="/dev/$DISK"
echo "Disco seleccionado: $DISK"

# --- Selección de usuario ---
read -rp "Nombre del usuario: " USERNAME
echo "Usuario: $USERNAME"

# --- Selección de locale ---
echo "Seleccione el locale principal:"
LOCALE=$(grep -v '^#' /etc/locale.gen | awk '{$1=$1};1' | fzf --height 15 --prompt="Locale: ")
echo "Locale seleccionado: $LOCALE"

echo "Seleccione la zona horaria:"
TIMEZONE=$(find /usr/share/zoneinfo -type f \
    | sed 's|/usr/share/zoneinfo/||' \
    | fzf --prompt="Seleccione su zona horaria: " --height=40% --border --ansi)
echo "Zona horaria seleccionada: $TIMEZONE"

# --- Selección de GPU ---
echo "Seleccione el fabricante de su GPU:"
GPU=$(printf "AMD\nIntel\nNvidia\nOmitir\n" | fzf --height 10 --prompt="GPU: ")
echo "GPU seleccionado: $GPU"

# --- Guardar variables para los otros scripts ---
cat <<EOF > /tmp_install_vars.sh
USERNAME="$USERNAME"
DISK="$DISK"
LOCALE="$LOCALE"
TIMEZONE="$TIMEZONE"
GPU="$GPU"
EOF

echo "✅ Variables guardadas en /tmp_install_vars.sh"
