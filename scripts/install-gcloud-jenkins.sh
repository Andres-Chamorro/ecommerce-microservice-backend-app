#!/bin/bash
# Script para instalar Google Cloud SDK en Jenkins

echo "📦 Instalando Google Cloud SDK en Jenkins..."

# Ejecutar dentro del contenedor de Jenkins
docker exec jenkins bash -c '
    # Actualizar repositorios
    apt-get update
    
    # Instalar dependencias
    apt-get install -y apt-transport-https ca-certificates gnupg curl
    
    # Agregar la clave GPG de Google Cloud
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    
    # Agregar el repositorio de Google Cloud SDK
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    
    # Actualizar e instalar gcloud
    apt-get update
    apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
    
    # Verificar instalación
    gcloud version
'

echo "✅ Google Cloud SDK instalado correctamente"
echo ""
echo "Ahora necesitas configurar las credenciales de GCP en Jenkins:"
echo "1. Copia tu archivo de credenciales JSON a Jenkins"
echo "2. Ejecuta: docker exec jenkins gcloud auth activate-service-account --key-file=/path/to/key.json"
echo "3. Configura el proyecto: docker exec jenkins gcloud config set project YOUR_PROJECT_ID"
