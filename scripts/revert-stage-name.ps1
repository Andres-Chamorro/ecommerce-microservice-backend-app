Write-Host "Revirtiendo nombre del stage a 'Deploy to Minikube'..." -ForegroundColor Cyan

$services = "user-service","product-service","order-service","payment-service","favourite-service","shipping-service"
$updated = 0

foreach ($svc in $services) {
    $file = "$svc/Jenkinsfile"
    if (Test-Path $file) {
        Write-Host "Procesando $file..." -ForegroundColor Yellow
        $text = Get-Content $file -Raw
        if ($text -match 'Deploy to Docker Desktop K8s') {
            $text = $text -replace "stage\('Deploy to Docker Desktop K8s'\)", "stage('Deploy to Minikube')"
            Set-Content $file $text -NoNewline
            Write-Host "Revertido OK" -ForegroundColor Green
            $updated++
        }
    }
}

Write-Host "Total revertidos: $updated archivos" -ForegroundColor Cyan
