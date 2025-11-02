# Script para copiar Jenkinsfile.staging a Jenkinsfile en la rama staging

Write-Host "Copiando Jenkinsfile.staging a Jenkinsfile en cada servicio..." -ForegroundColor Cyan

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    $stagingFile = "$service/Jenkinsfile.staging"
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $stagingFile) {
        Copy-Item $stagingFile $jenkinsfile -Force
        Write-Host "  Copiado $stagingFile -> $jenkinsfile" -ForegroundColor Green
    } else {
        Write-Host "  No se encontro $stagingFile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Proceso completado" -ForegroundColor Green
Write-Host "Ahora Jenkins detectara los Jenkinsfile de staging automaticamente" -ForegroundColor Cyan
