# Script para etiquetar y subir imagenes existentes a GCP
$PROJECT_ID = "ecommerce-microservices-476519"
$REGION = "us-central1"
$REGISTRY = "${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-registry"

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service",
    "api-gateway",
    "cloud-config",
    "service-discovery",
    "proxy-client"
)

Write-Host "=== Etiquetando y subiendo imagenes a GCP ===" -ForegroundColor Green
Write-Host ""

foreach ($service in $services) {
    $localImage = "ecommerce-${service}:latest"
    $gcpImage = "${REGISTRY}/ecommerce-${service}:latest"
    
    Write-Host "Procesando: $service" -ForegroundColor Cyan
    
    # Verificar si existe la imagen local
    $imageExists = docker images -q $localImage
    
    if ($imageExists) {
        Write-Host "  - Etiquetando..." -ForegroundColor Gray
        docker tag $localImage $gcpImage
        
        Write-Host "  - Subiendo a GCP..." -ForegroundColor Gray
        docker push $gcpImage
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  OK - $service subido" -ForegroundColor Green
        } else {
            Write-Host "  ERROR - Fallo al subir $service" -ForegroundColor Red
        }
    } else {
        Write-Host "  SKIP - Imagen local no encontrada" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "=== Proceso completado ===" -ForegroundColor Green
