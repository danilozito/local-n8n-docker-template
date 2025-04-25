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
    nvidia-cuda-toolkit \
    nvidia-cuda-toolkit-gcc \
    && rm -rf /var/lib/apt/lists/*

# Installa Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-dev python3.12-venv python3.12-distutils && \
    rm -rf /var/lib/apt/lists/*

# Installa pip per Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Crea un link simbolico per python3 e pip3
RUN ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3 && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip

# Installa librerie Python per ML/AI
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    tensorflow \
    torch \
    torchvision \
    jupyterlab \
    ipykernel

# Installa Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Installa estensioni utili di VS Code
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension njpwerner.autodocstring && \
    code-server --install-extension esbenp.prettier-vscode

# Ripristina l'utente coder
USER coder

# Configurazione dell'ambiente di lavoro
WORKDIR /home/coder/project/workspace 