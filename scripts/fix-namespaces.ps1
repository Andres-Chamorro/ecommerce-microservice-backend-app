$services = @("product-service", "order-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $file = "k8s\microservices\${service}-deployment.yaml"
    Write-Host "Actualizando namespace en $file..." -ForegroundColor Cyan
    
    $content = Get-Content $file -Raw
    $content = $content -replace "namespace: ecommerce-dev", "namespace: ecommerce-staging"
    $content | Set-Content $file -NoNewline
    
    Write-Host "  OK" -ForegroundColor Green
}

Write-Host "Namespaces actualizados" -ForegroundColor Green
