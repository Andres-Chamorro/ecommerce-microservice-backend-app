Write-Host "Actualizando ruta de kubectl en Jenkinsfiles..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar todos los comandos kubectl con la ruta completa
        $content = $content -replace 'docker exec minikube kubectl ', 'docker exec minikube /var/lib/minikube/binaries/v1.34.0/kubectl '
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles actualizados con ruta completa de kubectl" -ForegroundColor Green
