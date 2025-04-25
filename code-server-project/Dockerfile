FROM codercom/code-server:latest

USER root

# Installa le dipendenze di sistema
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    gnupg \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Installa pyenv per gestire versioni Python
RUN curl https://pyenv.run | bash

# Aggiungi pyenv a PATH e installa Python 3.12
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv install 3.12.2 && \
    pyenv global 3.12.2

# Verifica la versione Python
RUN python --version && \
    pip --version

# Installa librerie Python per ML/AI
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    jupyterlab \
    ipykernel

# Installa TensorFlow e PyTorch (useranno CUDA dall'host se disponibile)
RUN pip install --no-cache-dir \
    tensorflow \
    torch \
    torchvision

# Installa Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Installa estensioni utili di VS Code
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension njpwerner.autodocstring && \
    code-server --install-extension esbenp.prettier-vscode

# Ripristina l'utente coder (ma mantiene Python installato per root)
USER coder

# Crea un link simbolico di Python 3.12 nella cartella bin dell'utente coder
RUN mkdir -p ~/.local/bin && \
    ln -sf /root/.pyenv/shims/python ~/.local/bin/python && \
    ln -sf /root/.pyenv/shims/pip ~/.local/bin/pip

# Aggiungi la cartella bin al PATH dell'utente coder
ENV PATH="/home/coder/.local/bin:${PATH}"

# Configurazione dell'ambiente di lavoro
WORKDIR /home/coder/project/workspace 