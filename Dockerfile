FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
        apt-get install -y openssh-server sudo net-tools && \
        apt install -y nginx php8.1-fpm mariadb-server && \
        apt-get clean && \
        mkdir /var/run/sshd && \
        ssh-keygen -A

# NginX Konfiguration einfügen
RUN cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

COPY index.php /var/www/html/index.php
RUN rm /var/www/html/index.nginx-debian.html

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

COPY /start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
