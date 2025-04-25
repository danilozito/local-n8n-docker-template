#!/bin/sh

# Crea la directory per i certificati se non esiste
mkdir -p /etc/nginx/ssl

# Genera la chiave privata
openssl genrsa -out /etc/nginx/ssl/server.key 2048

# Genera il certificato self-signed
openssl req -new -x509 -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt -days 365 -subj "/CN=localhost"

# Imposta i permessi corretti
chmod 644 /etc/nginx/ssl/server.crt
chmod 600 /etc/nginx/ssl/server.key

# Mantiene il container in esecuzione
tail -f /dev/null 