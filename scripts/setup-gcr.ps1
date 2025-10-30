# Script para configurar Google Container Registry (GCR)
# Este script habilita GCR y configura Docker para usarlo

Write-Host "Configurando Google Container Registry (GCR)..." -ForegroundColor Cyan
Write-Host ""

# Variables
$PROJECT_ID = "ecommerce-microservices-476519"
$REGION = "us-central1"
$REGISTRY = "us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry"

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  PROJECT_ID: $PROJECT_ID"
Write-Host "  REGION: $REGION"
Write-Host "  REGISTRY: $REGISTRY"
Write-Host ""

# 1. Habilitar Artifact Registry API
Write-Host "1. Habilitando Artifact Registry API..." -ForegroundColor Green
gcloud services enable artifactregistry.googleapis.com --project=$PROJECT_ID

# 2. Verificar si el repositorio ya existe
Write-Host ""
Write-Host "2. Verificando repositorio..." -ForegroundColor Green
$repoExists = gcloud artifacts repositories describe ecommerce-registry --location=$REGION --project=$PROJECT_ID 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK Repositorio 'ecommerce-registry' ya existe" -ForegroundColor Green
} else {
    Write-Host "Creando repositorio 'ecommerce-registry'..." -ForegroundColor Yellow
    gcloud artifacts repositories create ecommerce-registry `
        --repository-format=docker `
        --location=$REGION `
        --description="Docker registry para microservicios de ecommerce" `
        --project=$PROJECT_ID
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK Repositorio creado exitosamente" -ForegroundColor Green
    } else {
        Write-Host "ERROR al crear repositorio" -ForegroundColor Red
        exit 1
    }
}

# 3. Configurar autenticacion de Docker con GCR
Write-Host ""
Write-Host "3. Configurando autenticacion de Docker..." -ForegroundColor Green
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK Docker autenticado con GCR" -ForegroundColor Green
} else {
    Write-Host "ERROR al configurar autenticacion" -ForegroundColor Red
    exit 1
}

# 4. Verificar que Jenkins puede acceder
Write-Host ""
Write-Host "4. Verificando permisos de Jenkins..." -ForegroundColor Green
if (Test-Path "jenkins-gcp-key.json") {
    Write-Host "OK Service account key encontrada: jenkins-gcp-key.json" -ForegroundColor Green
} else {
    Write-Host "WARNING: No se encontro jenkins-gcp-key.json" -ForegroundColor Yellow
    Write-Host "   Jenkins necesitara este archivo para autenticarse" -ForegroundColor Yellow
}

# 5. Mostrar informacion del registry
Write-Host ""
Write-Host "5. Informacion del Registry:" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Registry URL: $REGISTRY" -ForegroundColor White
Write-Host ""
Write-Host "Ejemplo de uso:" -ForegroundColor Yellow
Write-Host "  docker tag mi-imagen:latest $REGISTRY/mi-imagen:latest"
Write-Host "  docker push $REGISTRY/mi-imagen:latest"
Write-Host "  docker pull $REGISTRY/mi-imagen:latest"
Write-Host "========================================" -ForegroundColor Cyan

# 6. Probar el registry con una imagen de prueba
Write-Host ""
Write-Host "6. Probando el registry..." -ForegroundColor Green
Write-Host "Descargando imagen de prueba..."
docker pull hello-world:latest

Write-Host "Etiquetando imagen..."
docker tag hello-world:latest ${REGISTRY}/hello-world:test

Write-Host "Subiendo imagen al registry..."
docker push ${REGISTRY}/hello-world:test

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK Registry funcionando correctamente" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Limpiando imagen de prueba..."
    gcloud artifacts docker images delete ${REGISTRY}/hello-world:test --quiet 2>$null
} else {
    Write-Host "ERROR al subir imagen al registry" -ForegroundColor Red
    Write-Host "Verifica que tienes permisos en GCP" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Google Container Registry configurado" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Instalar Minikube (para ambiente DEV)" -ForegroundColor White
Write-Host "  2. Configurar Jenkins para usar jenkins-gcp-key.json" -ForegroundColor White
Write-Host "  3. Crear los 18 pipelines en Jenkins" -ForegroundColor White
Write-Host ""
