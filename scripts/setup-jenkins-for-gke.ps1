# Script para configurar Jenkins para GKE

Write-Host "Configurando Jenkins para GKE..." -ForegroundColor Cyan

# 1. Instalar gcloud SDK en Jenkins
Write-Host "`n1. Instalando gcloud SDK..." -ForegroundColor Yellow

docker exec -u root jenkins bash -c @"
cd /root
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh --quiet --path-update=true
rm google-cloud-cli-linux-x86_64.tar.gz
"@

Write-Host "  gcloud SDK instalado" -ForegroundColor Green

# 2. Instalar gke-gcloud-auth-plugin
Write-Host "`n2. Instalando gke-gcloud-auth-plugin..." -ForegroundColor Yellow

docker exec -u root jenkins bash -c @"
/root/google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin --quiet
"@

Write-Host "  gke-gcloud-auth-plugin instalado" -ForegroundColor Green

# 3. Copiar credenciales de GCP (si existen)
Write-Host "`n3. Configurando credenciales de GCP..." -ForegroundColor Yellow

if (Test-Path "$env:APPDATA\gcloud\application_default_credentials.json") {
    docker exec jenkins mkdir -p /var/jenkins_home/.config/gcloud
    docker cp "$env:APPDATA\gcloud\application_default_credentials.json" jenkins:/var/jenkins_home/.config/gcloud/
    docker exec jenkins chown -R jenkins:jenkins /var/jenkins_home/.config
    Write-Host "  Credenciales copiadas" -ForegroundColor Green
} else {
    Write-Host "  WARNING: No se encontraron credenciales locales" -ForegroundColor Yellow
    Write-Host "  Necesitaras autenticar manualmente o usar service account" -ForegroundColor Yellow
}

# 4. Configurar kubectl para GKE
Write-Host "`n4. Configurando kubectl para GKE..." -ForegroundColor Yellow

docker exec jenkins bash -c @"
export PATH=/root/google-cloud-sdk/bin:\$PATH
/root/google-cloud-sdk/bin/gcloud container clusters get-credentials ecommerce-staging-cluster \
    --zone=us-central1-a \
    --project=ecommerce-microservices-476519 \
    --internal-ip 2>/dev/null || echo 'Necesita autenticacion'
"@

Write-Host "  kubectl configurado" -ForegroundColor Green

# 5. Verificar instalacion
Write-Host "`n5. Verificando instalacion..." -ForegroundColor Yellow

Write-Host "`nVerificando gcloud:"
docker exec jenkins bash -c "/root/google-cloud-sdk/bin/gcloud version" 2>&1 | Select-Object -First 3

Write-Host "`nVerificando kubectl:"
docker exec jenkins kubectl version --client 2>&1 | Select-Object -First 2

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nPROXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "1. Autenticar gcloud en Jenkins (si no se copiaron credenciales)"
Write-Host "2. Configurar Docker para autenticar con Artifact Registry"
Write-Host "3. Probar el pipeline de staging"
Write-Host "`nPara autenticar manualmente:"
Write-Host "  docker exec -it jenkins bash"
Write-Host "  /root/google-cloud-sdk/bin/gcloud auth login"
Write-Host "  /root/google-cloud-sdk/bin/gcloud auth configure-docker us-central1-docker.pkg.dev"
