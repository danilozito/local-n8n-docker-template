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

## Architettura Unificata

Il progetto utilizza un unico file docker-compose.yml che include tutti i servizi:

1. **Database**:
   - PostgreSQL - Database relazionale per n8n
   - Qdrant - Database vettoriale per funzionalità AI

2. **AI**:
   - Ollama - Modelli di linguaggio locali con supporto GPU

3. **Applicazioni**:
   - n8n - Piattaforma di automazione no-code
   - code-server - VS Code nel browser con strumenti per AI/ML preinstallati

## Accesso ai Servizi

- **n8n**: http://<TUO_IP>:5678
- **code-server**: http://<TUO_IP>:8080 (password: codeserver!2025)
- **Ollama API**: http://<TUO_IP>:11434
- **Qdrant UI**: http://<TUO_IP>:6334
- **pgAdmin**: http://<TUO_IP>:8081 (default email: admin@tuodominio.it, password: changeme)

## Ambiente code-server per AI/ML

Code-server è configurato con un ambiente di sviluppo completo per AI/ML:

- **Python 3.12** con pyenv
- **Librerie per Data Science e ML**:
  - NumPy, Pandas, Matplotlib
  - scikit-learn
  - TensorFlow
  - PyTorch
  - JupyterLab
- **Node.js** per sviluppo web
- **Estensioni VS Code** preinstallate per Python e Jupyter

Tutte le librerie AI/ML sono già configurate per utilizzare la GPU se disponibile.

## Workspace per Progetti

Code-server è configurato con una struttura workspace organizzata:

- La directory principale del progetto è montata in `/home/coder/project/workspace`
- Puoi creare nuovi progetti o modificare file direttamente da code-server

Per creare un nuovo progetto:
1. Accedi a code-server (http://tuo-server:8080)
2. Apri un terminale in code-server
3. Crea una nuova directory di progetto:
   ```bash
   mkdir -p /home/coder/project/workspace/nuovo-progetto
   cd /home/coder/project/workspace/nuovo-progetto
   ```

## Integrazione tra n8n e Ollama

Per utilizzare Ollama da n8n:

1. In n8n, crea una nuova credenziale HTTP:
   - Settings → Credentials → Add → HTTP
   - Nome: "Ollama API"
   - URL base: `http://ollama:11434`

2. Crea un workflow che utilizza la credenziale:
   - Aggiungi un nodo HTTP Request
   - Seleziona la credenziale "Ollama API"
   - Metodo: POST
   - Endpoint: `/api/generate`
   - Body:
   ```json
   {
     "model": "llama3",
     "prompt": "Ciao, come stai?",
     "stream": false
   }
   ```

## Risoluzione dei Problemi

Se riscontri problemi con un servizio specifico, puoi controllare i log:

```bash
docker logs <container-name>
```

Per una verifica dello stato dettagliata:

```bash
./deploy.sh debug
```

## Note

- Le configurazioni sono persistenti nei volumi Docker
- Tutti i servizi sono configurati per riavviarsi automaticamente in caso di crash
- Puoi personalizzare ulteriormente le configurazioni modificando il file docker-compose.yml