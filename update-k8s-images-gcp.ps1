# Script para actualizar las imágenes en los manifiestos de Kubernetes para GCP
# Uso: .\update-k8s-images-gcp.ps1

# CONFIGURACIÓN - REEMPLAZA CON TU PROJECT_ID
$PROJECT_ID = Read-Host "Ingresa tu GCP Project ID"
$REGION = "us-central1"
$REGISTRY = "${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-registry"
$VERSION = "latest"

Write-Host "🔄 Actualizando manifiestos de Kubernetes para GCP..." -ForegroundColor Green
Write-Host "  Registry: $REGISTRY" -ForegroundColor Cyan
Write-Host ""

# Actualizar deployments en k8s/microservices/
$microservices = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $microservices) {
    $file = "k8s\microservices\${service}-deployment.yaml"
    if (Test-Path $file) {
        Write-Host "  📝 Actualizando: $file" -ForegroundColor Cyan
        
        # Leer contenido
        $content = Get-Content $file -Raw
        
        # Reemplazar imagen
        $newImage = "${REGISTRY}/ecommerce-${service}:${VERSION}"
        $content = $content -replace 'image:\s+.*ecommerce-.*service.*', "image: $newImage"
        
        # Guardar
        $content | Set-Content $file -NoNewline
        
        Write-Host "    ✅ Imagen actualizada a: $newImage" -ForegroundColor Green
    } else {
        Write-Host "    ⚠️  Archivo no encontrado: $file" -ForegroundColor Yellow
    }
}

Write-Host ""

# Actualizar infrastructure
$infrastructure = @(
    "api-gateway",
    "cloud-config",
    "service-discovery"
)

foreach ($service in $infrastructure) {
    $file = "k8s\infrastructure\${service}-deployment.yaml"
    if (Test-Path $file) {
        Write-Host "  📝 Actualizando: $file" -ForegroundColor Cyan
        
        # Leer contenido
        $content = Get-Content $file -Raw
        
        # Reemplazar imagen
        $newImage = "${REGISTRY}/ecommerce-${service}:${VERSION}"
        $content = $content -replace 'image:\s+.*', "image: $newImage"
        
        # Guardar
        $content | Set-Content $file -NoNewline
        
        Write-Host "    ✅ Imagen actualizada a: $newImage" -ForegroundColor Green
    } else {
        Write-Host "    ⚠️  Archivo no encontrado: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Manifiestos actualizados!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Verifica los cambios:" -ForegroundColor Cyan
Write-Host "   git diff k8s/" -ForegroundColor White
Write-Host ""
Write-Host "📋 Próximo paso:" -ForegroundColor Cyan
Write-Host "   kubectl apply -f k8s/infrastructure/ -n ecommerce-staging" -ForegroundColor White
Write-Host "   kubectl apply -f k8s/microservices/ -n ecommerce-staging" -ForegroundColor White
