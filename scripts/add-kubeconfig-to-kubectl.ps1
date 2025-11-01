Write-Host "Agregando kubeconfig a comandos kubectl..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Agregar --kubeconfig a todos los comandos kubectl
        $content = $content -replace 'docker exec minikube /var/lib/minikube/binaries/v1\.34\.0/kubectl ', 'docker exec minikube /var/lib/minikube/binaries/v1.34.0/kubectl --kubeconfig=/etc/kubernetes/admin.conf '
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles actualizados con kubeconfig" -ForegroundColor Green
