# Local n8n Docker Template

Template Docker per l'implementazione locale di n8n con integrazione di Ollama, Qdrant e PostgreSQL.

## Requisiti

- Docker
- Docker Compose
- Git

## Setup Iniziale

1. Clona il repository:
   ```bash
   git clone https://github.com/danilozito/local-n8n-docker-template.git
   cd local-n8n-docker-template
   ```

2. Crea la directory per code-server:
   ```bash
   mkdir code-server-project
   cd code-server-project
   ```

3. Crea il file docker-compose.yml per code-server:
   ```bash
   cat > docker-compose.yml << 'EOL'
   version: '3.8'

   volumes:
     code_server_config:
     code_server_data:

   services:
     code-server:
       image: codercom/code-server:latest
       container_name: code-server
       restart: always
       environment:
         - PUID=1000
         - PGID=1000
         - TZ=Europe/Rome
         - CODE_SERVER_PASSWORD=${CODE_SERVER_PASSWORD}
       volumes:
         - code_server_config:/home/coder/.config
         - code_server_data:/home/coder/project
         - ../:/home/coder/project/workspace
       ports:
         - "8080:8080"
   EOL
   ```

4. Crea il file .env per code-server:
   ```bash
   cat > .env << 'EOL'
   CODE_SERVER_PASSWORD=la_tua_password
   EOL
   ```

5. Avvia code-server:
   ```bash
   docker compose up -d
   ```

6. Accedi all'editor web:
   - URL: http://tuo-server:8080
   - Usa la password configurata nel file .env

## Configurazione di n8n

1. Una volta accesso a code-server:
   - File -> Open Folder
   - Seleziona `/home/coder/project/workspace`

2. Configura il file .env per n8n:
   - Naviga fino al file `.env.example`
   - Copia il contenuto in un nuovo file `.env`
   - Modifica le variabili d'ambiente secondo le tue necessità

## Deploy del Progetto

1. Dalla cartella principale del progetto:
   ```bash
   cd ..
   ```

2. Avvia i container:
   ```bash
   docker compose up -d
   ```

3. Verifica che tutti i servizi siano in esecuzione:
   ```bash
   docker compose ps
   ```

4. Accedi a n8n:
   - URL: https://tuo-server
   - Usa le credenziali configurate nel file .env

## Struttura del Progetto

Il progetto è diviso in due parti:

1. **Progetto n8n** (root directory):
   - n8n: Automazione workflow
   - ollama: AI locale
   - qdrant: Vector database
   - postgres: Database
   - nginx: Reverse proxy con SSL

2. **Progetto code-server** (code-server-project):
   - Editor web basato su VS Code
   - Accesso alla directory parent per editing remoto
   - Configurazione persistente

## Gestione dei Servizi

### Code Server
- Per fermare code-server:
  ```bash
  cd code-server-project
  docker compose down
  ```
- Per riavviare code-server:
  ```bash
  docker compose up -d
  ```

### n8n e Servizi Correlati
- Per fermare tutti i servizi:
  ```bash
  docker compose down
  ```
- Per riavviare tutti i servizi:
  ```bash
  docker compose up -d
  ```
- Per vedere i log:
  ```bash
  docker compose logs -f
  ```

## Note

- Le configurazioni sono persistenti nei volumi Docker
- Code-server supporta estensioni e temi di VS Code
- Il progetto n8n è accessibile solo via HTTPS (porta 443)
- Code-server è accessibile via HTTP (porta 8080)
- Tutti i servizi sono configurati per riavviarsi automaticamente in caso di crash 