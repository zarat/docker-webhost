#!/bin/bash

# Starte SSH
echo "Starte SSH..."
/usr/sbin/sshd

# Starte Nginx im Vordergrund
echo "Starte Nginx..."
nginx -g "daemon off;"
