Write-Host "Actualizando Jenkinsfiles para Docker Desktop..." -ForegroundColor Cyan

$services = "user-service","product-service","order-service","payment-service","favourite-service","shipping-service"
$updated = 0

foreach ($svc in $services) {
    $file = "$svc/Jenkinsfile"
    if (Test-Path $file) {
        Write-Host "Procesando $file..." -ForegroundColor Yellow
        $text = Get-Content $file -Raw
        if ($text -match 'Deploy to Minikube') {
            $text = $text -replace "stage\('Deploy to Minikube'\)", "stage('Deploy to Docker Desktop K8s')"
            $text = $text -replace 'sh """', 'bat """'
            $text = $text -replace 'export KUBECONFIG.*', 'kubectl config use-context docker-desktop'
            $text = $text -replace 'kubectl config set-cluster minikube.*', ''
            $text = $text -replace 'kubectl config set-credentials minikube-user.*', ''
            $text = $text -replace 'kubectl config set-context minikube.*', ''
            $text = $text -replace 'kubectl config use-context minikube', 'REM Usando docker-desktop context'
            $text = $text -replace 'kubectl cluster-info', 'kubectl get nodes'
            Set-Content $file $text -NoNewline
            Write-Host "Actualizado OK" -ForegroundColor Green
            $updated++
        }
    }
}

Write-Host "Total actualizados: $updated archivos" -ForegroundColor Cyan
