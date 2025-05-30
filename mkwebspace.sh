#!/bin/bash

read -p "Kunden Name: " kunde
read -p "Kunden Port: " port

# Name des Docker-Containers
CONTAINER_NAME=$kunde
SERVER_NAME="$kunde.zarat.cloudns.nz"

sudo docker run -dit --name $kunde -p $port:22 ubuntu-template

# Container-IP ermitteln
CONTAINER_IP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

if [ -z "$CONTAINER_IP" ]; then
  echo "Fehler: Container $CONTAINER_NAME läuft nicht oder hat keine IP."
  exit 1
fi

# vHost-Datei erzeugen
cat <<EOF | sudo tee "/etc/nginx/sites-available/$kunde" > /dev/null
server {
    listen 80;
    server_name $kunde.zarat.cloudns.nz;

    location / {
        proxy_pass http://$CONTAINER_IP:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Symlink setzen
sudo ln -s "/etc/nginx/sites-available/$kunde" "/etc/nginx/sites-enabled/$kunde"

# Nginx Konfiguration testen und neuladen
sudo nginx -t && sudo systemctl reload nginx

echo "vHost für kundeE wurde erstellt  $CONTAINER_IP)"
