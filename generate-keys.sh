#!/bin/bash

# Script per generare chiavi di sicurezza casuali per n8n
# Da eseguire prima del primo avvio

# Controlla se il file .env esiste
if [ ! -f .env ]; then
    echo "File .env non trovato. Creando file .env da .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        echo "File .env.example non trovato. Creando un nuovo file .env..."
        touch .env
        echo "POSTGRES_USER=n8n" >> .env
        echo "POSTGRES_PASSWORD=n8n" >> .env
        echo "POSTGRES_DB=n8n" >> .env
    fi
fi

# Genera una chiave di crittografia casuale
ENCRYPTION_KEY=$(openssl rand -hex 24)

# Genera un JWT secret casuale
JWT_SECRET=$(openssl rand -hex 32)

# Cerca e sostituisci le variabili nel file .env, o aggiungile se non esistono
if grep -q "N8N_ENCRYPTION_KEY" .env; then
    # Sostituisci la variabile esistente
    sed -i.bak "s/N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY/" .env && rm .env.bak
else
    # Aggiungi la variabile se non esiste
    echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" >> .env
fi

if grep -q "N8N_USER_MANAGEMENT_JWT_SECRET" .env; then
    # Sostituisci la variabile esistente
    sed -i.bak "s/N8N_USER_MANAGEMENT_JWT_SECRET=.*/N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET/" .env && rm .env.bak
else
    # Aggiungi la variabile se non esiste
    echo "N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET" >> .env
fi

echo "Chiavi di sicurezza generate e salvate in .env"
echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY"
echo "N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET"

echo "Ora puoi avviare i container con: docker compose up -d" 