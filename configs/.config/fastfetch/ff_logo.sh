#!/bin/bash

# Directorio donde guardás tus logos
LOGO_DIR="$HOME/.config/fastfetch/logos"

# Si no existe, avisamos y salimos
[ ! -d "$LOGO_DIR" ] && {
    echo "Error: No se encontró el directorio $LOGO_DIR" >&2
    exit 1
}

# Buscar imágenes válidas (png / icon / webp)
LOGOS=$(find -L "$LOGO_DIR" -maxdepth 1 -type f \
    \( -iname "*.png" -o -iname "*.icon" -o -iname "*.webp" \) 2>/dev/null)

# Si no hay archivos válidos, error
[ -z "$LOGOS" ] && {
    echo "Error: No se encontraron PNG/ICON en $LOGO_DIR" >&2
    exit 1
}

# Elegir uno al azar
printf "%s\n" "$LOGOS" | shuf -n 1

