# Script completo para desplegar en GCP
# Uso: .\deploy-to-gcp.ps1

$PROJECT_ID = "ecommerce-microservices-476519"
$REGION = "us-central1"
$REGISTRY = "${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-registry"

Write-Host "🚀 Desplegando Ecommerce Microservices en GCP" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  Project: $PROJECT_ID" -ForegroundColor Cyan
Write-Host "  Registry: $REGISTRY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 1: Build y Push imágenes
Write-Host "📦 PASO 1: Build y Push de imágenes Docker" -ForegroundColor Yellow
Write-Host ""
.\build-and-push-gcp.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error en build y push" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 2: Actualizar manifiestos
Write-Host "📝 PASO 2: Actualizar manifiestos de Kubernetes" -ForegroundColor Yellow
Write-Host ""
.\update-k8s-images-gcp.ps1

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 3: Crear namespaces
Write-Host "📁 PASO 3: Crear namespaces en Kubernetes" -ForegroundColor Yellow
Write-Host ""

kubectl create namespace ecommerce-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ecommerce-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ecommerce-prod --dry-run=client -o yaml | kubectl apply -f -

Write-Host "  ✅ Namespaces creados" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 4: Desplegar infraestructura
Write-Host "🏗️  PASO 4: Desplegar infraestructura" -ForegroundColor Yellow
Write-Host ""

kubectl apply -f k8s/infrastructure/ -n ecommerce-staging

Write-Host "  ⏳ Esperando a que la infraestructura esté lista..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 5: Desplegar microservicios
Write-Host "🚀 PASO 5: Desplegar microservicios" -ForegroundColor Yellow
Write-Host ""

kubectl apply -f k8s/microservices/ -n ecommerce-staging

Write-Host "  ✅ Microservicios desplegados" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 6: Verificar deployment
Write-Host "🔍 PASO 6: Verificar deployment" -ForegroundColor Yellow
Write-Host ""

Write-Host "  📊 Pods:" -ForegroundColor Cyan
kubectl get pods -n ecommerce-staging

Write-Host ""
Write-Host "  📊 Services:" -ForegroundColor Cyan
kubectl get services -n ecommerce-staging

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Paso 7: Obtener IP pública
Write-Host "🌐 PASO 7: Obtener IP pública del API Gateway" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ⏳ Esperando a que se asigne IP externa..." -ForegroundColor Cyan
Write-Host "  (Esto puede tomar 2-3 minutos)" -ForegroundColor Gray
Write-Host ""

$maxAttempts = 20
$attempt = 0
$apiIp = $null

while ($attempt -lt $maxAttempts -and -not $apiIp) {
    $attempt++
    $apiIp = kubectl get service api-gateway -n ecommerce-staging -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    
    if ($apiIp) {
        break
    }
    
    Write-Host "  Intento $attempt/$maxAttempts..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

if ($apiIp) {
    Write-Host ""
    Write-Host "  ✅ IP Pública obtenida: $apiIp" -ForegroundColor Green
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎉 ¡Deployment completado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 URLs de acceso:" -ForegroundColor Cyan
    Write-Host "  🌐 API Gateway: http://${apiIp}:8080" -ForegroundColor White
    Write-Host "  🏥 Health Check: http://${apiIp}:8080/actuator/health" -ForegroundColor White
    Write-Host "  👤 Users API: http://${apiIp}:8080/api/users" -ForegroundColor White
    Write-Host "  📦 Products API: http://${apiIp}:8080/api/products" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "  Ver pods: kubectl get pods -n ecommerce-staging" -ForegroundColor Gray
    Write-Host "  Ver logs: kubectl logs <pod-name> -n ecommerce-staging" -ForegroundColor Gray
    Write-Host "  Ver servicios: kubectl get services -n ecommerce-staging" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🧪 Probar la aplicación:" -ForegroundColor Cyan
    Write-Host "  curl http://${apiIp}:8080/actuator/health" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "  ⚠️  No se pudo obtener la IP externa automáticamente" -ForegroundColor Yellow
    Write-Host "  Ejecuta manualmente: kubectl get services -n ecommerce-staging" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
