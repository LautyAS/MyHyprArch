#!/bin/bash
set -e  # Que se detenga si hay algún error

echo "=== Iniciando instalación de Arch Linux con Hyprland ==="

./01-check_disk.sh
./02-format_mount.sh
./03-install_base.sh
./04-config_system.sh
./05-install_aur_tools.sh
./06-post_install.sh
./07-ricing.sh

echo "=== Instalación finalizada! ==="
