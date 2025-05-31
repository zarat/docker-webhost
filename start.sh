#!/bin/bash

# Starte SSH
echo "Starte SSH..."
/usr/sbin/sshd

echo "Starte PHP8.1 FPM"
sudo service php8.1-fpm start

# Starte Nginx im Vordergrund
echo "Starte Nginx..."
nginx -g "daemon off;"
