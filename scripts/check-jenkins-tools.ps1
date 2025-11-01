Write-Host "Verificando herramientas disponibles en Jenkins..." -ForegroundColor Cyan

Write-Host "`n1. Verificando Docker CLI en Jenkins..." -ForegroundColor Yellow
docker exec jenkins docker --version

Write-Host "`n2. Verificando kubectl en Jenkins..." -ForegroundColor Yellow
docker exec jenkins kubectl version --client 2>&1

Write-Host "`n3. Verificando Maven en Jenkins..." -ForegroundColor Yellow
docker exec jenkins mvn --version 2>&1

Write-Host "`n4. Verificando Java en Jenkins..." -ForegroundColor Yellow
docker exec jenkins java -version 2>&1

Write-Host "`n5. Verificando kubeconfig en Jenkins..." -ForegroundColor Yellow
docker exec jenkins ls -la /var/jenkins_home/.kube/ 2>&1

Write-Host "`nVerificacion completa" -ForegroundColor Green
