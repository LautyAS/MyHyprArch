#!/bin/bash
set -e

echo "=== 01 - Selección de disco ==="
echo ""

# Mostrar discos disponibles
lsblk -dpno NAME,SIZE,MODEL | grep -v "loop"
echo ""

# Pedir al usuario que seleccione un disco
while true; do
    read -rp "Ingrese el disco a usar (ej: /dev/sda): " INSTALL_DISK
    # Verificar que exista
    if [[ -b "$INSTALL_DISK" ]]; then
        echo "Ha seleccionado el disco: $INSTALL_DISK"
        read -rp "¿Es correcto? [y/N]: " CONFIRM
        case "$CONFIRM" in
            [yY][eE][sS]|[yY]) 
                export INSTALL_DISK
                echo "Disco $INSTALL_DISK confirmado."
                break
                ;;
            *) 
                echo "Selecciona nuevamente."
                ;;
        esac
    else
        echo "Disco no válido. Intenta de nuevo."
    fi
done

# Guardar la variable para los siguientes scripts (opcional)
echo "export INSTALL_DISK=$INSTALL_DISK" > /tmp/install_disk.sh
