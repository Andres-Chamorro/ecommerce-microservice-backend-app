#!/bin/bash

# Script para instalar herramientas necesarias en Jenkins
# Este script debe ejecutarse en el agente de Jenkins

set -e

echo "🔧 Instalando herramientas necesarias para el pipeline..."

# Actualizar repositorios
apt-get update

# Instalar dependencias básicas
apt-get install -y \
    openjdk-17-jdk \
    maven \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https

# Configurar Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> /etc/environment
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/environment

# Instalar Docker CLI
if ! command -v docker &> /dev/null; then
    echo "📦 Instalando Docker CLI..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce-cli
else
    echo "✅ Docker CLI ya está instalado"
fi

# Instalar kubectl
if ! command -v kubectl &> /dev/null; then
    echo "☸️ Instalando kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
else
    echo "✅ kubectl ya está instalado"
fi

# Instalar Google Cloud CLI
if ! command -v gcloud &> /dev/null; then
    echo "☁️ Instalando Google Cloud CLI..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    apt-get update && apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
else
    echo "✅ gcloud CLI ya está instalado"
fi

# Verificar instalaciones
echo ""
echo "🔍 Verificando instalaciones:"
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn --version
echo ""
echo "Docker version:"
docker --version
echo ""
echo "kubectl version:"
kubectl version --client
echo ""
echo "gcloud version:"
gcloud version

echo ""
echo "✅ Todas las herramientas están instaladas correctamente"
echo "🚀 El agente de Jenkins está listo para ejecutar el pipeline"