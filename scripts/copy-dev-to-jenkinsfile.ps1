Write-Host "Copiando Jenkinsfile.dev a Jenkinsfile en todos los servicios..." -ForegroundColor Cyan

$services = @(
    "user-service",
    "order-service",
    "product-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $services) {
    $sourceFile = "$service/Jenkinsfile.dev"
    $targetFile = "$service/Jenkinsfile"
    
    if (Test-Path $sourceFile) {
        Write-Host "Copiando $sourceFile a $targetFile..." -ForegroundColor Yellow
        
        Copy-Item -Path $sourceFile -Destination $targetFile -Force
        
        Write-Host "OK $targetFile actualizado" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $sourceFile no encontrado" -ForegroundColor Red
    }
}

Write-Host "`nTodos los Jenkinsfile actualizados" -ForegroundColor Green
Write-Host "Jenkins ahora puede usar los archivos:" -ForegroundColor Cyan
foreach ($service in $services) {
    Write-Host "  - $service/Jenkinsfile" -ForegroundColor White
}
