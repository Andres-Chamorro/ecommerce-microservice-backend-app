Write-Host "Reconstruyendo Jenkins con Maven, Docker CLI y kubectl..." -ForegroundColor Cyan

Write-Host "`n1. Deteniendo Jenkins actual..." -ForegroundColor Yellow
docker-compose -f docker-compose.jenkins.yml down

Write-Host "`n2. Construyendo nueva imagen de Jenkins con herramientas..." -ForegroundColor Yellow
docker-compose -f docker-compose.jenkins.yml build

Write-Host "`n3. Iniciando Jenkins con herramientas instaladas..." -ForegroundColor Yellow
docker-compose -f docker-compose.jenkins.yml up -d

Write-Host "`n4. Esperando a que Jenkins inicie (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n5. Verificando herramientas instaladas..." -ForegroundColor Yellow
Write-Host "`nMaven:" -ForegroundColor Cyan
docker exec jenkins mvn --version

Write-Host "`nDocker CLI:" -ForegroundColor Cyan
docker exec jenkins docker --version

Write-Host "`nkubectl:" -ForegroundColor Cyan
docker exec jenkins kubectl version --client

Write-Host "`nJenkins reconstruido con todas las herramientas necesarias" -ForegroundColor Green
Write-Host "Accede a Jenkins en: http://localhost:8079" -ForegroundColor Cyan
