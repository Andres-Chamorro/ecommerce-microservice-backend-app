$services = @("product-service", "order-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $file = "k8s\microservices\${service}-deployment.yaml"
    Write-Host "Actualizando health checks en $file..." -ForegroundColor Cyan
    
    $content = Get-Content $file -Raw
    
    # Actualizar liveness probe
    $content = $content -replace "initialDelaySeconds: 90", "initialDelaySeconds: 180"
    $content = $content -replace "initialDelaySeconds: 60", "initialDelaySeconds: 120"
    $content = $content -replace "periodSeconds: 10", "periodSeconds: 30"
    $content = $content -replace "timeoutSeconds: 5", "timeoutSeconds: 10"
    $content = $content -replace "failureThreshold: 3", "failureThreshold: 5"
    
    $content | Set-Content $file -NoNewline
    
    Write-Host "  OK" -ForegroundColor Green
}

Write-Host "Health checks actualizados" -ForegroundColor Green
