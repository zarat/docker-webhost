#!/bin/bash

# Kundenname
read -p "Bitte gib einen Kunden-namen ein: " kunde

echo "Entferne Container"
sudo docker stop $kunde
sudo docker rm $kunde

echo "Entferne NginX VHost Konfiguration"
sudo rm "/etc/nginx/sites-available/$kunde"
sudo rm "/etc/nginx/sites-enabled/$kunde"

echo "Lade NginX neu"
# Nginx-Konfiguration testen und neu laden
sudo nginx -t && sudo systemctl reload nginx

echo "VHost $kunde wurde entfernt."
