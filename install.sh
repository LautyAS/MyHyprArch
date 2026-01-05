#!/bin/bash
set -e  # Que se detenga si hay algún error

echo "=== Iniciando instalación de Arch Linux con Hyprland ==="

./01-options.sh
./02-install_base.sh
./03-config.sh
./04-hyprland.sh

cp -r rice/* /mnt/root/rice
cp -r configs/* /mnt/root/configs

./05-ricing.sh

echo "=== Instalación finalizada! ==="
printf "Se recomienda encarecidamente instalar fwupd, con eso podés verificar actualizaciones de firmware ejecutando:\n  fwupdmgr get-devices\n  fwupdmgr get-updates"
