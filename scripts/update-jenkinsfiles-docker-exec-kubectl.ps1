Write-Host "Actualizando Jenkinsfiles para usar docker exec minikube kubectl..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar todos los comandos kubectl con docker exec minikube kubectl
        $content = $content -replace 'kubectl ', 'docker exec minikube kubectl '
        
        # Remover la configuracion de KUBECONFIG ya que no es necesaria
        $content = $content -replace '\s+# Configurar KUBECONFIG explÃ­citamente\r?\n\s+export KUBECONFIG=/var/jenkins_home/\.kube/config\r?\n\s+\r?\n', "`n"
        $content = $content -replace '\s+# Cambiar contexto a Minikube\r?\n\s+docker exec minikube kubectl config use-context minikube\r?\n\s+\r?\n', "`n"
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles actualizados para usar docker exec minikube kubectl" -ForegroundColor Green
Write-Host "Ahora Jenkins ejecutara kubectl dentro del contenedor de Minikube" -ForegroundColor Cyan
