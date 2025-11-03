# Script para instalar una version compatible del plugin JUnit

Write-Host "Instalando version compatible del plugin JUnit..." -ForegroundColor Cyan

$jenkinsContainer = docker ps --filter "name=jenkins" --format "{{.Names}}" | Select-Object -First 1

if ([string]::IsNullOrEmpty($jenkinsContainer)) {
    Write-Host "Error: No se encontro el contenedor de Jenkins" -ForegroundColor Red
    exit 1
}

Write-Host "Deteniendo Jenkins temporalmente..." -ForegroundColor Yellow
docker exec $jenkinsContainer java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080/ safe-shutdown 2>$null
Start-Sleep -Seconds 5

Write-Host "Eliminando version problematica del plugin JUnit..." -ForegroundColor Yellow
docker exec $jenkinsContainer rm -rf /var/jenkins_home/plugins/junit*

Write-Host "Instalando version compatible del plugin JUnit (1.60)..." -ForegroundColor Cyan
docker exec $jenkinsContainer jenkins-plugin-cli --plugins junit:1.60

Write-Host "Reiniciando Jenkins..." -ForegroundColor Cyan
docker restart $jenkinsContainer

Write-Host ""
Write-Host "Jenkins reiniciado con version compatible de JUnit" -ForegroundColor Green
Write-Host "Espera 2-3 minutos para que Jenkins inicie completamente" -ForegroundColor Yellow
