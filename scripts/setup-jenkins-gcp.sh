#!/bin/bash

# Script para configurar acceso de Jenkins a GKE
# Este script debe ejecutarse DENTRO del contenedor de Jenkins

echo "🔧 Configurando acceso de Jenkins a GKE..."

# Variables (ajustar según tu configuración)
GCP_PROJECT_ID="ecommerce-microservices-476519"
GCP_ZONE="us-central1-a"
GKE_CLUSTER="ecommerce-staging-cluster"

# 1. Instalar gcloud CLI si no está instalado
if ! command -v gcloud &> /dev/null; then
    echo "📦 Instalando Google Cloud CLI..."
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    . ~/google-cloud-sdk/path.bash.inc
fi

# 2. Instalar gke-gcloud-auth-plugin
echo "📦 Instalando gke-gcloud-auth-plugin..."
gcloud components install gke-gcloud-auth-plugin --quiet

# 3. Verificar que existe la service account key
if [ ! -f "/var/jenkins_home/gcp-key.json" ]; then
    echo "❌ ERROR: No se encontró /var/jenkins_home/gcp-key.json"
    echo "Por favor, copia tu service account key a este archivo"
    exit 1
fi

# 4. Autenticar con GCP
echo "🔐 Autenticando con GCP..."
gcloud auth activate-service-account --key-file=/var/jenkins_home/gcp-key.json
gcloud config set project ${GCP_PROJECT_ID}

# 5. Configurar kubectl para GKE
echo "☸️ Configurando kubectl para GKE..."
gcloud container clusters get-credentials ${GKE_CLUSTER} --zone=${GCP_ZONE}

# 6. Verificar conexión
echo "✅ Verificando conexión..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "✅ Configuración completada!"
echo "Ahora Jenkins puede acceder al cluster de GKE"
