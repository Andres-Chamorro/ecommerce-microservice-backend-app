FROM jenkins/jenkins:lts-jdk17

USER root

# Instalar Docker CLI
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Instalar kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Instalar Maven
RUN apt-get install -y maven

# Instalar Python3 y pip para pruebas de rendimiento con Locust
RUN apt-get install -y python3 python3-pip python3-venv

# Instalar Locust globalmente (seguro en contenedor)
RUN pip3 install --break-system-packages locust

# Instalar Google Cloud SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-linux-x86_64.tar.gz -C /root && \
    /root/google-cloud-sdk/install.sh --quiet && \
    rm google-cloud-cli-linux-x86_64.tar.gz

# Limpiar cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER jenkins
