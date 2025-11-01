Write-Host "Corrigiendo pipes en comandos kubectl..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Corrigiendo $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Corregir el comando con pipe para crear namespace
        $content = $content -replace 'docker exec minikube kubectl create namespace \$\{K8S_NAMESPACE\} --dry-run=client -o yaml \| docker exec minikube kubectl apply -f -', 'docker exec minikube kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -'
        
        # Corregir el comando con pipe para aplicar deployment
        $content = $content -replace 'cat <<EOF \| docker exec minikube kubectl apply -f -', 'cat <<EOF | docker exec -i minikube kubectl apply -f -'
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile corregido" -ForegroundColor Green
    }
}

Write-Host "`nPipes corregidos en todos los Jenkinsfiles" -ForegroundColor Green
