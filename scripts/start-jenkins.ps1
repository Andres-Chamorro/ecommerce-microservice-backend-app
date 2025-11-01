Write-Host "Iniciando Jenkins..." -ForegroundColor Cyan

# Verificar si el contenedor existe
$containerExists = docker ps -a --filter "name=jenkins" --format "{{.Names}}"

if ($containerExists) {
    Write-Host "Contenedor Jenkins encontrado. Eliminando..." -ForegroundColor Yellow
    docker rm -f jenkins
}

Write-Host "Iniciando Jenkins con docker-compose..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "`nEsperando a que Jenkins inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "`nVerificando estado de Jenkins..." -ForegroundColor Yellow
docker ps --filter "name=jenkins"

Write-Host "`n✅ Jenkins iniciado!" -ForegroundColor Green
Write-Host "Accede a: http://localhost:8079" -ForegroundColor Cyan
Write-Host "`nPara ver los logs: docker logs -f jenkins" -ForegroundColor Yellow
