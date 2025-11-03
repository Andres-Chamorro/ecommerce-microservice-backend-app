# Script para arreglar la instalación de Locust en todos los Jenkinsfiles de staging
# Elimina el intento de crear venv e instalar locust (ya está en el Dockerfile)

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.staging"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar el bloque de instalación de locust
        $content = $content -replace "# Crear virtual environment e instalar locust\s+python3 -m venv /tmp/locust-venv \|\| true\s+\. /tmp/locust-venv/bin/activate\s+pip3 install locust \|\| echo `"Error instalando Locust`"\s+", ""
        
        # Simplificar comentario
        $content = $content -replace "# Ejecutar Locust en modo headless \(sin UI\)", "# Ejecutar Locust en modo headless (sin UI) - locust ya esta instalado en Jenkins"
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "Actualizado $jenkinsfile" -ForegroundColor Green
    } else {
        Write-Host "No encontrado $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Todos los Jenkinsfiles de staging actualizados" -ForegroundColor Green
Write-Host "Ahora necesitas reconstruir la imagen de Jenkins con:" -ForegroundColor Yellow
Write-Host "   docker-compose build jenkins" -ForegroundColor Cyan
Write-Host "   docker-compose up -d jenkins" -ForegroundColor Cyan
