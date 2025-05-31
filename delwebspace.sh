#!/bin/bash

# Kundenname
read -p "Bitte gib einen Kunden-namen ein: " kunde

#echo "Stoppe Container"
#sudo docker stop $kunde > /dev/null

echo "Entferne Container"
sudo docker rm $kunde -f > /dev/null

echo "Entferne vHost Konfiguration"
sudo rm "/etc/nginx/sites-available/$kunde"
sudo rm "/etc/nginx/sites-enabled/$kunde"

echo "Lade NginX neu"
sudo nginx -t && sudo systemctl reload nginx

echo "VHost $kunde wurde entfernt."
