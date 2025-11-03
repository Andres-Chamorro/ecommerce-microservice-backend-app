Write-Host "Actualizando Jenkinsfiles para usar Minikube..." -ForegroundColor Cyan

$services = "user-service","product-service","order-service","payment-service","favourite-service","shipping-service"
$updated = 0

foreach ($svc in $services) {
    $file = "$svc/Jenkinsfile"
    if (Test-Path $file) {
        Write-Host "Procesando $file..." -ForegroundColor Yellow
        $text = Get-Content $file -Raw
        $text = $text -replace 'kubectl config use-context docker-desktop', 'kubectl config use-context minikube'
        Set-Content $file $text -NoNewline
        Write-Host "Actualizado OK" -ForegroundColor Green
        $updated++
    }
}

Write-Host "Total actualizados: $updated archivos" -ForegroundColor Cyan
