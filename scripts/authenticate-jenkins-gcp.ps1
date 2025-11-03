# Script para autenticar Jenkins con GCP usando credenciales locales

Write-Host "Autenticando Jenkins con GCP..." -ForegroundColor Cyan

# 1. Verificar si hay credenciales locales
$credsPath = "$env:APPDATA\gcloud\application_default_credentials.json"

if (Test-Path $credsPath) {
    Write-Host "`n1. Copiando credenciales de GCP..." -ForegroundColor Yellow
    
    docker exec jenkins mkdir -p /var/jenkins_home/.config/gcloud
    docker cp $credsPath jenkins:/var/jenkins_home/.config/gcloud/
    docker exec jenkins chown -R jenkins:jenkins /var/jenkins_home/.config
    
    Write-Host "  Credenciales copiadas" -ForegroundColor Green
} else {
    Write-Host "`nWARNING: No se encontraron credenciales locales" -ForegroundColor Red
    Write-Host "Ejecuta: gcloud auth application-default login" -ForegroundColor Yellow
    exit 1
}

# 2. Configurar proyecto
Write-Host "`n2. Configurando proyecto..." -ForegroundColor Yellow

docker exec jenkins /root/google-cloud-sdk/bin/gcloud config set project ecommerce-microservices-476519

Write-Host "  Proyecto configurado" -ForegroundColor Green

# 3. Configurar Docker para Artifact Registry
Write-Host "`n3. Configurando Docker para Artifact Registry..." -ForegroundColor Yellow

docker exec jenkins /root/google-cloud-sdk/bin/gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

Write-Host "  Docker configurado" -ForegroundColor Green

# 4. Configurar kubectl para GKE
Write-Host "`n4. Configurando kubectl para GKE..." -ForegroundColor Yellow

docker exec jenkins /root/google-cloud-sdk/bin/gcloud container clusters get-credentials ecommerce-staging-cluster `
    --zone=us-central1-a `
    --project=ecommerce-microservices-476519

Write-Host "  kubectl configurado" -ForegroundColor Green

# 5. Crear namespace si no existe
Write-Host "`n5. Creando namespace ecommerce-staging..." -ForegroundColor Yellow

docker exec jenkins kubectl create namespace ecommerce-staging 2>&1 | Out-Null
docker exec jenkins kubectl get namespace ecommerce-staging

Write-Host "  Namespace listo" -ForegroundColor Green

# 6. Verificar configuración
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFICACION FINAL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nVerificando autenticacion gcloud:"
docker exec jenkins /root/google-cloud-sdk/bin/gcloud auth list 2>&1 | Select-Object -First 3

Write-Host "`nVerificando acceso a GKE:"
docker exec jenkins kubectl cluster-info 2>&1 | Select-Object -First 2

Write-Host "`nVerificando namespaces:"
docker exec jenkins kubectl get namespaces | Select-String "ecommerce"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nJenkins esta listo para desplegar en GKE Staging" -ForegroundColor Cyan
