#!/bin/bash

# Script per il deploy semplificato con un unico file docker-compose

# Colori per i log
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# IP del server (modifica secondo le tue esigenze)
SERVER_IP="192.168.0.49"

log() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] ${GREEN}$1${NC}"
}

error() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warn() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Ferma tutti i container
stop_all() {
  log "Arresto di tutti i servizi..."
  docker compose down
  log "Tutti i container sono stati fermati."
  exit 0
}

# Controlla se è stato richiesto l'arresto
if [ "$1" = "stop" ]; then
  stop_all
fi

# Controlla se è stato richiesto il debug
if [ "$1" = "debug" ]; then
  log "Modalità debug: verifica dello stato dei container..."
  docker ps -a
  
  log "Log di Ollama:"
  docker logs ollama | tail -30
  
  log "Controllando se Ollama risponde:"
  docker exec -it ollama wget --spider --quiet http://localhost:11434 && echo "Ollama risponde" || echo "Ollama non risponde"
  
  log "Test comando ollama all'interno del container:"
  docker exec -it ollama ollama --help
  
  exit 0
fi

# Imposta valori predefiniti per le variabili d'ambiente
if [ ! -f .env ]; then
  log "File .env non trovato, creazione in corso..."
  echo "POSTGRES_USER=n8n" > .env
  echo "POSTGRES_PASSWORD=n8n" >> .env
  echo "POSTGRES_DB=n8n" >> .env
  echo "N8N_HOST=$SERVER_IP" >> .env
  
  # Genera chiavi di sicurezza casuali
  ENCRYPTION_KEY=$(openssl rand -hex 24)
  JWT_SECRET=$(openssl rand -hex 32)
  
  echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" >> .env
  echo "N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET" >> .env
  
  log "File .env creato con le chiavi di sicurezza generate"
fi

# Crea directory necessarie con i permessi corretti
log "Creazione directory necessarie..."
mkdir -p projects shared 
sudo mkdir -p n8n/demo-data
sudo mkdir -p n8n/demo-data/credentials n8n/demo-data/workflows
sudo touch n8n/demo-data/credentials/.gitkeep n8n/demo-data/workflows/.gitkeep
sudo chmod -R 777 n8n

# Avvia i container
log "Avvio di tutti i servizi..."

# Costruzione dell'immagine code-server personalizzata
log "Costruzione dell'immagine code-server personalizzata (potrebbe richiedere alcuni minuti la prima volta)..."
docker compose down 2>/dev/null || true
docker compose up -d

log "Verifica lo stato dei container:"
docker ps

# Verifica che i servizi siano pronti
log "Attesa per PostgreSQL..."
attempt=1
max_attempts=30
until docker exec postgres pg_isready -h localhost -U ${POSTGRES_USER:-n8n} -d ${POSTGRES_DB:-n8n} > /dev/null 2>&1; do
  if [ $attempt -eq $max_attempts ]; then
    error "PostgreSQL non è diventato disponibile in tempo. Controlla i log con: docker logs postgres"
    break
  fi
  log "Attesa per PostgreSQL ($attempt/$max_attempts)..."
  sleep 2
  attempt=$((attempt+1))
done
if [ $attempt -lt $max_attempts ]; then
  log "PostgreSQL è pronto!"
fi

log "Attesa per Ollama..."
attempt=1
max_attempts=30
until docker exec ollama curl -s -o /dev/null -w "%{http_code}" http://localhost:11434/api/health | grep -q "200"; do
  if [ $attempt -eq $max_attempts ]; then
    warn "Ollama potrebbe non essere pronto. Continuiamo comunque..."
    break
  fi
  log "Attesa per Ollama ($attempt/$max_attempts)..."
  sleep 2
  attempt=$((attempt+1))
done
if [ $attempt -lt $max_attempts ]; then
  log "Ollama è pronto!"
fi

log "Attesa per code-server..."
attempt=1
max_attempts=30
until docker logs code-server 2>&1 | grep -q "HTTP server listening"; do
  if [ $attempt -eq $max_attempts ]; then
    warn "Timeout durante l'attesa di code-server. Controlla i log con: docker logs code-server"
    break
  fi
  log "Attesa per code-server ($attempt/$max_attempts)..."
  sleep 2
  attempt=$((attempt+1))
done
if [ $attempt -lt $max_attempts ]; then
  log "code-server è pronto!"
fi

# Mostra informazioni di accesso
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${PURPLE}INFORMAZIONI DI ACCESSO${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "n8n:         ${YELLOW}http://$SERVER_IP:5678${NC}"
echo -e "code-server: ${YELLOW}http://$SERVER_IP:8080${NC} (password: codeserver!2025)"
echo -e "Ollama API:  ${YELLOW}http://$SERVER_IP:11434${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "Note: ${YELLOW}code-server viene avviato con Python, Node.js, TensorFlow, PyTorch e altre librerie AI/ML preinstallate${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "Per visualizzare i logs: ${BLUE}docker logs <container-name>${NC}"
echo -e "Per fermare tutto: ${BLUE}./deploy.sh stop${NC}"
echo -e "${GREEN}==========================================${NC}\n" 