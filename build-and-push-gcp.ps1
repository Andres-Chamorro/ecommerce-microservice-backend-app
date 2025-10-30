# Script para construir y subir imágenes a Google Cloud Artifact Registry
# Uso: .\build-and-push-gcp.ps1

# CONFIGURACIÓN - REEMPLAZA CON TU PROJECT_ID
$PROJECT_ID = Read-Host "Ingresa tu GCP Project ID"
$REGION = "us-central1"
$REGISTRY = "${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-registry"
$VERSION = "1.0.0"

Write-Host "🚀 Configuración:" -ForegroundColor Green
Write-Host "  Project ID: $PROJECT_ID" -ForegroundColor Cyan
Write-Host "  Registry: $REGISTRY" -ForegroundColor Cyan
Write-Host "  Version: $VERSION" -ForegroundColor Cyan
Write-Host ""

# Verificar autenticación
Write-Host "🔐 Verificando autenticación con GCP..." -ForegroundColor Yellow
gcloud auth configure-docker ${REGION}-docker.pkg.dev

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: No estás autenticado con GCP" -ForegroundColor Red
    Write-Host "Ejecuta: gcloud auth login" -ForegroundColor Yellow
    exit 1
}

# Lista de servicios
$services = @(
    "api-gateway",
    "cloud-config",
    "service-discovery",
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service",
    "proxy-client"
)

Write-Host "🚀 Construyendo y subiendo imágenes a GCP Artifact Registry..." -ForegroundColor Green
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($service in $services) {
    Write-Host "📦 Procesando: $service" -ForegroundColor Cyan
    
    # Build de la imagen
    Write-Host "  🔨 Building..." -ForegroundColor Yellow
    docker build -t "${REGISTRY}/ecommerce-${service}:${VERSION}" `
                 -t "${REGISTRY}/ecommerce-${service}:latest" `
                 -f "${service}/Dockerfile" .
    
    if ($LASTEXITCODE -eq 0) {
        # Push de la imagen
        Write-Host "  ⬆️  Pushing version ${VERSION}..." -ForegroundColor Yellow
        docker push "${REGISTRY}/ecommerce-${service}:${VERSION}"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ⬆️  Pushing latest..." -ForegroundColor Yellow
            docker push "${REGISTRY}/ecommerce-${service}:latest"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✅ $service completado" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "  ❌ Error al subir latest de $service" -ForegroundColor Red
                $failCount++
            }
        } else {
            Write-Host "  ❌ Error al subir $service" -ForegroundColor Red
            $failCount++
        }
    } else {
        Write-Host "  ❌ Error al construir $service" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📊 Resumen:" -ForegroundColor Green
Write-Host "  ✅ Exitosos: $successCount" -ForegroundColor Green
Write-Host "  ❌ Fallidos: $failCount" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "✅ Proceso completado!" -ForegroundColor Green
    Write-Host "📋 Verifica tus imágenes en:" -ForegroundColor Cyan
    Write-Host "   https://console.cloud.google.com/artifacts/docker/${PROJECT_ID}/${REGION}/ecommerce-registry" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔍 O desde CLI:" -ForegroundColor Cyan
    Write-Host "   gcloud artifacts docker images list ${REGISTRY}" -ForegroundColor White
}

if ($failCount -gt 0) {
    Write-Host "⚠️  Algunos servicios fallaron. Revisa los errores arriba." -ForegroundColor Yellow
    exit 1
}
