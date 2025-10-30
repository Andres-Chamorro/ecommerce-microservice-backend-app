# Script para copiar Jenkinsfile.dev a Jenkinsfile en cada servicio
# Jenkins usa Jenkinsfile (sin .dev) por defecto

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Copiando Jenkinsfile.dev a Jenkinsfile en cada servicio..." -ForegroundColor Cyan

foreach ($service in $services) {
    $jenkinsfileDev = "$service/Jenkinsfile.dev"
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfileDev) {
        Write-Host "`nCopiando $jenkinsfileDev -> $jenkinsfile..." -ForegroundColor Yellow
        
        # Copiar contenido
        Copy-Item -Path $jenkinsfileDev -Destination $jenkinsfile -Force
        
        Write-Host "  Copiado!" -ForegroundColor Green
    } else {
        Write-Host "  No encontrado: $jenkinsfileDev" -ForegroundColor Red
    }
}

Write-Host "`nCopia completada!" -ForegroundColor Green
Write-Host "Ahora Jenkins usara la configuracion actualizada con docker save/load" -ForegroundColor White
