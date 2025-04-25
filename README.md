# Local n8n Docker Template

Template Docker per l'implementazione locale di n8n con integrazione di Ollama, Qdrant, PostgreSQL e code-server.

## Requisiti

- Docker
- Docker Compose
- Git
- NVIDIA GPU con driver installati (per le funzionalità AI)

## Setup Iniziale

1. Clona il repository:
   ```bash
   git clone https://github.com/danilozito/local-n8n-docker-template.git
   cd local-n8n-docker-template
   ```

2. Configura il file .env:
   ```bash
   # Copia il file .env.example
   cp .env.example .env
   
   # Modifica il file .env con le tue impostazioni
   nano .env
   ```

3. Avvia l'intero stack con un solo comando:
   ```bash
   docker compose up -d
   ```

4. Verifica che tutti i servizi siano in esecuzione:
   ```bash
   docker compose ps
   ```

5. Accedi ai servizi:
   - **n8n**: https://tuo-server/
   - **code-server**: https://tuo-server/code/ (password: codeserver!2025)

## Utilizzo dei Progetti con GPU

Per utilizzare la GPU nei tuoi progetti:

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

3. Crea i tuoi script Python con supporto GPU:
   ```python
   # esempio.py
   import tensorflow as tf
   print("Dispositivi GPU disponibili:", tf.config.list_physical_devices('GPU'))
   
   # Il tuo codice ML/AI qui
   ```

4. Esegui i tuoi script:
   ```bash
   python esempio.py
   ```

Per notebook Jupyter:
1. Crea un file con estensione `.ipynb` nel tuo progetto
2. Il supporto Jupyter si attiverà automaticamente in code-server
3. I notebook avranno accesso alla GPU configurata

## Struttura del Progetto

Il progetto include:

- **n8n**: Automazione workflow
- **ollama**: AI locale con accesso GPU
- **qdrant**: Vector database
- **postgres**: Database relazionale
- **nginx**: Reverse proxy con SSL
- **code-server**: Editor web basato su VS Code con Python 3.12 e supporto GPU

### Workspace per Progetti

Code-server è configurato con una struttura workspace organizzata:

- `/home/coder/workspace/` è la directory principale per tutti i progetti
- `/home/coder/workspace/n8n-project/` contiene il progetto n8n stesso
- È possibile creare altre cartelle di progetto direttamente in `/home/coder/workspace/` 

Per creare un nuovo progetto:
1. Accedi a code-server (https://tuo-server/code/)
2. Apri un terminale in code-server
3. Crea una nuova directory di progetto:
   ```bash
   mkdir -p /home/coder/workspace/nuovo-progetto
   cd /home/coder/workspace/nuovo-progetto
   ```
4. Inizia a lavorare sul tuo progetto

Tutti i progetti creati in `/home/coder/workspace/` saranno persistenti grazie al volume Docker dedicato.

## Accesso Sicuro tramite HTTPS

Entrambi i servizi n8n e code-server sono configurati per essere accessibili tramite HTTPS:

- **n8n**: https://tuo-server/
- **code-server**: https://tuo-server/code/

La configurazione HTTPS è gestita tramite Nginx come reverse proxy, che utilizza certificati SSL generati automaticamente. I certificati sono self-signed, quindi potresti ricevere un avviso dal browser la prima volta che accedi. Puoi accettare l'eccezione o, per un ambiente di produzione, sostituire i certificati con certificati validi di Let's Encrypt.

### Personalizzazione dei Certificati SSL

Se desideri utilizzare certificati validi:

1. Modifica il generatore SSL in `nginx/Dockerfile`
2. Sostituisci i certificati generati con certificati validi
3. Riavvia il container nginx

## Gestione dei Servizi

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

- Per vedere i log di un servizio specifico:
  ```bash
  docker compose logs -f service_name
  ```

## Note

- Le configurazioni sono persistenti nei volumi Docker
- Code-server supporta estensioni e temi di VS Code
- Il progetto n8n è accessibile solo via HTTPS (porta 443)
- Code-server è accessibile via HTTPS all'indirizzo https://tuo-server/code/
- Tutti i servizi sono configurati per riavviarsi automaticamente in caso di crash