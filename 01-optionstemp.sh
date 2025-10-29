#!/bin/bash
set -e

echo "=== 01-options.sh: Configuración inicial interactiva ==="

# --- Función de selección con fzf ---
select_fzf() {
    echo "$1" | fzf --height 15 --prompt="$2: "
}

# --- Selección de disco ---
echo "Seleccione el disco para la instalación:"
DISK=$(lsblk -d -o NAME,SIZE,MODEL | grep -v "loop" | select_fzf "Disco")
DISK="/dev/$DISK"
echo "Disco seleccionado: $DISK"

# --- Selección de usuario ---
read -rp "Nombre del usuario: " USERNAME
echo "Usuario: $USERNAME"

# --- Selección de locale ---
echo "Seleccione el locale principal:"
LOCALE=$(grep -v '^#' /etc/locale.gen | select_fzf "Locale")
echo "Locale seleccionado: $LOCALE"

# --- Selección de zona horaria ---
echo "Seleccione la zona horaria:"
TIMEZONE=$(find /usr/share/zoneinfo -type f | sed 's|/usr/share/zoneinfo/||' | select_fzf "Zona horaria")
echo "Zona horaria seleccionada: $TIMEZONE"

# --- Selección de GPU ---
echo "Seleccione el fabricante de su GPU:"
GPU=$(printf "AMD\nIntel\nNvidia\nOmitir" | select_fzf "GPU")
echo "GPU seleccionado: $GPU"

# --- Guardar variables ---
cat <<EOF > /tmp_install_vars.sh
USERNAME="$USERNAME"
DISK="$DISK"
LOCALE="$LOCALE"
TIMEZONE="$TIMEZONE"
GPU="$GPU"
EOF

echo "✅ Variables guardadas en /tmp_install_vars.sh"
