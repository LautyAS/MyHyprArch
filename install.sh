#!/bin/bash
set -e  # Que se detenga si hay algún error

echo "=== Iniciando instalación de Arch Linux con Hyprland ==="

./01-options.sh
./02-install_base.sh
./03-config.sh
./04-hyprland.sh
./05-ricing.sh

echo "=== Instalación finalizada! ==="
