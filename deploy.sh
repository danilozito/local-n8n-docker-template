#!/bin/bash

# Script per il deploy dei container in ordine

# Colori per i log
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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
  log "Arresto delle applicazioni..."
  docker compose -f docker-compose.apps.yml down

  log "Arresto di Ollama..."
  docker compose -f docker-compose.ai.yml down

  log "Arresto dei database..."
  docker compose -f docker-compose.db.yml down

  log "Tutti i container sono stati fermati."
  exit 0
}

# Controlla se è stato richiesto l'arresto
if [ "$1" = "stop" ]; then
  stop_all
fi

# Imposta valori predefiniti per le variabili d'ambiente
if [ ! -f .env ]; then
  log "File .env non trovato, creazione in corso..."
  echo "POSTGRES_USER=n8n" > .env
  echo "POSTGRES_PASSWORD=n8n" >> .env
  echo "POSTGRES_DB=n8n" >> .env
  
  # Genera chiavi di sicurezza casuali
  ENCRYPTION_KEY=$(openssl rand -hex 24)
  JWT_SECRET=$(openssl rand -hex 32)
  
  echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" >> .env
  echo "N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET" >> .env
  
  log "File .env creato con le chiavi di sicurezza generate"
fi

# Crea directory necessarie
mkdir -p projects shared n8n/demo-data
mkdir -p n8n/demo-data/credentials n8n/demo-data/workflows
touch n8n/demo-data/credentials/.gitkeep n8n/demo-data/workflows/.gitkeep

# Crea network
log "Creazione della rete Docker..."
docker network create n8n_network 2>/dev/null || true

# FASE 1: Deploy database
log "1/3 - Deploy dei database (PostgreSQL e Qdrant)..."
docker compose -f docker-compose.db.yml down -v 2>/dev/null || true
docker compose -f docker-compose.db.yml up -d

# Attendi che postgres sia pronto
log "Attesa per PostgreSQL..."
attempt=1
max_attempts=30
until docker exec postgres pg_isready -h localhost -U ${POSTGRES_USER:-n8n} -d ${POSTGRES_DB:-n8n} > /dev/null 2>&1; do
  if [ $attempt -eq $max_attempts ]; then
    error "PostgreSQL non è diventato disponibile in tempo. Controlla i log con: docker logs postgres"
    exit 1
  fi
  log "Attesa per PostgreSQL ($attempt/$max_attempts)..."
  sleep 2
  attempt=$((attempt+1))
done
log "PostgreSQL è pronto!"

# FASE 2: Deploy Ollama
log "2/3 - Deploy di Ollama (AI)..."
docker compose -f docker-compose.ai.yml down 2>/dev/null || true
docker compose -f docker-compose.ai.yml up -d

# Attendi che Ollama sia pronto
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

# FASE 3: Deploy applicazioni
log "3/3 - Deploy delle applicazioni (n8n, code-server, nginx)..."
docker compose -f docker-compose.apps.yml down 2>/dev/null || true
docker compose -f docker-compose.apps.yml up -d

log "Verifica lo stato dei container:"
docker ps

# Attendi che code-server sia pronto
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
echo -e "n8n:         ${YELLOW}http://localhost:5678${NC}"
echo -e "code-server: ${YELLOW}http://localhost:8080${NC} (password: codeserver!2025)"
echo -e "HTTPS via nginx: ${YELLOW}https://localhost${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "Per visualizzare i logs: ${BLUE}docker logs <container-name>${NC}"
echo -e "Per fermare tutto: ${BLUE}./deploy.sh stop${NC}"
echo -e "${GREEN}==========================================${NC}\n" 