# Script simplificado para desplegar en GKE
$PROJECT_ID = "ecommerce-microservices-476519"
$REGION = "us-central1"
$REGISTRY = "${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-registry"

Write-Host "=== Desplegando en GKE ===" -ForegroundColor Green
Write-Host "Project: $PROJECT_ID" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Crear namespaces
Write-Host "Paso 1: Creando namespaces..." -ForegroundColor Yellow
kubectl create namespace ecommerce-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ecommerce-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ecommerce-prod --dry-run=client -o yaml | kubectl apply -f -
Write-Host "OK - Namespaces creados" -ForegroundColor Green
Write-Host ""

# Paso 2: Desplegar infraestructura
Write-Host "Paso 2: Desplegando infraestructura..." -ForegroundColor Yellow
kubectl apply -f k8s/infrastructure/ -n ecommerce-staging
Write-Host "OK - Infraestructura desplegada" -ForegroundColor Green
Write-Host ""

Write-Host "Esperando 60 segundos a que la infraestructura inicie..." -ForegroundColor Cyan
Start-Sleep -Seconds 60

# Paso 3: Desplegar microservicios
Write-Host "Paso 3: Desplegando microservicios..." -ForegroundColor Yellow
kubectl apply -f k8s/microservices/ -n ecommerce-staging
Write-Host "OK - Microservicios desplegados" -ForegroundColor Green
Write-Host ""

# Paso 4: Ver estado
Write-Host "Paso 4: Estado del deployment" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n ecommerce-staging
Write-Host ""
Write-Host "Services:" -ForegroundColor Cyan
kubectl get services -n ecommerce-staging
Write-Host ""

Write-Host "=== Deployment completado ===" -ForegroundColor Green
Write-Host ""
Write-Host "Para obtener la IP publica:" -ForegroundColor Cyan
Write-Host 'kubectl get service api-gateway -n ecommerce-staging' -ForegroundColor White
