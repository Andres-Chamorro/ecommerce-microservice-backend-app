# Script simple para reconstruir Jenkins con Locust

Write-Host "Reconstruyendo imagen de Jenkins con Locust..." -ForegroundColor Cyan

# Reconstruir la imagen
Write-Host "Construyendo imagen..." -ForegroundColor Yellow
docker-compose -f docker-compose.jenkins.yml build jenkins

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al construir la imagen" -ForegroundColor Red
    exit 1
}

# Reiniciar el contenedor
Write-Host "Reiniciando Jenkins..." -ForegroundColor Yellow
docker-compose -f docker-compose.jenkins.yml up -d jenkins

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al reiniciar Jenkins" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "COMPLETADO" -ForegroundColor Green
Write-Host "Jenkins se esta reiniciando con Locust instalado" -ForegroundColor Green
Write-Host "Tus datos estan seguros en el volumen jenkins_home" -ForegroundColor Green
Write-Host ""
Write-Host "Espera 30-60 segundos y accede a: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para verificar Locust:" -ForegroundColor Yellow
Write-Host "docker-compose -f docker-compose.jenkins.yml exec jenkins locust --version" -ForegroundColor White
