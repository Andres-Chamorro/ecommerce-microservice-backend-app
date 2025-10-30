$REGISTRY = "us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry"

$services = @("product-service", "order-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $file = "k8s\microservices\${service}-deployment.yaml"
    Write-Host "Actualizando $file..." -ForegroundColor Cyan
    
    $content = Get-Content $file -Raw
    $content = $content -replace "image: ecommerce-${service}:latest", "image: ${REGISTRY}/ecommerce-${service}:latest"
    $content | Set-Content $file -NoNewline
    
    Write-Host "  OK" -ForegroundColor Green
}

Write-Host "Manifiestos actualizados" -ForegroundColor Green
