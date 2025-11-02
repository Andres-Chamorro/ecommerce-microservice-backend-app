#!/bin/bash
# Script para instalar gcloud SDK en Jenkins

echo "Instalando gcloud SDK en Jenkins..."

# Instalar gcloud SDK
cd /root
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh --quiet --path-update=true
rm google-cloud-cli-linux-x86_64.tar.gz

# Instalar gke-gcloud-auth-plugin
/root/google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin --quiet

echo "gcloud SDK instalado correctamente"
/root/google-cloud-sdk/bin/gcloud version
