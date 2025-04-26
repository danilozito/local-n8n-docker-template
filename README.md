# Local n8n Docker Template

Template Docker per l'implementazione locale di n8n con integrazione di Ollama, Qdrant, PostgreSQL e code-server.

## Requisiti

- Docker
- Docker Compose
- Git
- NVIDIA GPU con driver installati (per le funzionalità AI)

## Setup Iniziale Semplificato

1. Clona il repository:
   ```bash
   git clone https://github.com/danilozito/local-n8n-docker-template.git
   cd local-n8n-docker-template
   ```

2. Rendi eseguibile lo script di deploy:
   ```bash
   chmod +x deploy.sh
   ```

3. Avvia l'ambiente completo:
   ```bash
   ./deploy.sh
   ```

4. Per fermare tutti i servizi:
   ```bash
   ./deploy.sh stop
   ```

## Architettura Modulare

Il progetto utilizza un'architettura modulare con diversi file docker-compose:

1. **docker-compose.db.yml** - Database:
   - PostgreSQL
   - Qdrant

2. **docker-compose.ai.yml** - AI:
   - Ollama

3. **docker-compose.apps.yml** - Applicazioni:
   - n8n
   - code-server
   - nginx

Lo script `deploy.sh` avvia i container nell'ordine corretto, con verifiche di disponibilità.

## Accesso ai Servizi

- **n8n**: http://tuo-server:5678
- **code-server**: http://tuo-server:8080 (password: codeserver!2025)
- **HTTPS via nginx**: https://tuo-server/

## Workspace per Progetti

Code-server è configurato con una struttura workspace organizzata:

- `/home/coder/workspace/` è la directory principale per tutti i progetti
- `/home/coder/workspace/n8n-project/` contiene il progetto n8n stesso
- È possibile creare altre cartelle di progetto direttamente in `/home/coder/workspace/` 

Per creare un nuovo progetto:
1. Accedi a code-server (http://tuo-server:8080)
2. Apri un terminale in code-server
3. Crea una nuova directory di progetto:
   ```bash
   mkdir -p /home/coder/workspace/nuovo-progetto
   cd /home/coder/workspace/nuovo-progetto
   ```

## Utilizzo della GPU con Python

Per utilizzare la GPU nei tuoi progetti Python:

1. Crea un nuovo progetto o accedi a uno esistente:
   ```bash
   mkdir -p /home/coder/workspace/ml-project
   cd /home/coder/workspace/ml-project
   ```

2. Verifica l'accesso alla GPU:
   ```bash
   # Verifica la disponibilità della GPU
   nvidia-smi
   
   # Verifica che TensorFlow possa accedere alla GPU
   python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
   
   # Verifica che PyTorch possa accedere alla GPU
   python -c "import torch; print('CUDA disponibile:', torch.cuda.is_available())"
   ```

## Risoluzione dei Problemi

Se riscontri problemi con un servizio specifico, puoi controllare i log:

```bash
docker logs <container-name>
```

Puoi anche gestire individualmente i servizi:

```bash
# Solo database
docker compose -f docker-compose.db.yml up -d

# Solo AI
docker compose -f docker-compose.ai.yml up -d

# Solo applicazioni
docker compose -f docker-compose.apps.yml up -d
```

## Note

- Le configurazioni sono persistenti nei volumi Docker
- Tutti i servizi sono configurati per riavviarsi automaticamente in caso di crash
- Puoi personalizzare ulteriormente le configurazioni modificando i file docker-compose specifici