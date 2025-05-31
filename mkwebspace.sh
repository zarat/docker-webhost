#!/bin/bash

read -p "Name: " kunde
read -p "externer SSH-Port: " port
read -p "Username: " username

password=$username!

# Name des Docker-Containers
CONTAINER_NAME=$kunde
SERVER_NAME="$kunde.zarat.cloudns.nz"


echo "Erstelle Docker Container..."
if sudo docker run -dit --name "$kunde" --hostname "$kunde.zarat.cloudns.nz" -p "$port":22 ubuntu-template > /dev/null 2>&1; then
    echo " Container erfolgreich erstellt."
else
    echo " Fehler beim Erstellen des Containers."
fi

#sudo docker exec "$kunde" bash -c "sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
sudo docker exec "$kunde" bash -c "useradd -m -s /bin/bash $username && echo '$username:$password' | chpasswd"
sudo docker exec "$kunde" bash -c "usermod -aG sudo $username"
echo " Benutzer '$username' mit Passwort '$password' wurde erstellt. Login via SSH ist jetzt möglich."


# Container-IP ermitteln
CONTAINER_IP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

if [ -z "$CONTAINER_IP" ]; then
  echo "Fehler: Container $CONTAINER_NAME läuft nicht oder hat keine IP."
  exit 1
fi

echo "Erstelle vHost Konfiguration"
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

server {
    listen 443;
    server_name $kunde.zarat.cloudns.nz;

    location / {
        proxy_pass http://$CONTAINER_IP:443;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "Aktiviere vHost"
# Symlink setzen
sudo ln -s "/etc/nginx/sites-available/$kunde" "/etc/nginx/sites-enabled/$kunde"

echo "Lade NginX neu"
# Nginx Konfiguration testen und neuladen
sudo nginx -t && sudo systemctl reload nginx

echo "vHost wurde erstellt ($CONTAINER_IP)"
