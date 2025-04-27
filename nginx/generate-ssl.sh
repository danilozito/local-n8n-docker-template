#!/bin/sh

# Ottieni il CN (Common Name) dal primo argomento o usa "localhost" come default
CN=${1:-localhost}

# Crea la directory per i certificati se non esiste
mkdir -p /ssl

# Genera la chiave privata
openssl genrsa -out /ssl/server.key 2048

# Genera il certificato self-signed con il CN appropriato
openssl req -new -x509 -key /ssl/server.key -out /ssl/server.crt -days 365 -subj "/CN=$CN"

# Imposta i permessi corretti
chmod 644 /ssl/server.crt
chmod 600 /ssl/server.key

echo "Certificato generato per CN=$CN"

# Mantiene il container in esecuzione
tail -f /dev/null 