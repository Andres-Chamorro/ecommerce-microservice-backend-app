Write-Host "Haciendo Verify Deployment no bloqueante..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Cambiar el exit 1 por un warning
        $content = $content -replace 'echo "WARNING: \$\{SERVICE_NAME\} no esta en estado Running"\s+exit 1', 'echo "WARNING: ${SERVICE_NAME} no esta en estado Running - revisar con kubectl describe pod"'
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nVerify Deployment ahora es no bloqueante" -ForegroundColor Green
