FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y openssh-server sudo net-tools nginx && apt-get clean && mkdir /var/run/sshd && ssh-keygen -A

COPY index.html /var/www/html/index.html
RUN rm /var/www/html/index.nginx-debian.html

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

COPY /start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
