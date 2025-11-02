# Script para actualizar el plugin JUnit y sus dependencias en Jenkins

Write-Host "Actualizando plugins de Jenkins para resolver NoClassDefFoundError..." -ForegroundColor Cyan

# Obtener el contenedor de Jenkins
$jenkinsContainer = docker ps --filter "name=jenkins" --format "{{.Names}}" | Select-Object -First 1

if ([string]::IsNullOrEmpty($jenkinsContainer)) {
    Write-Host "Error: No se encontro el contenedor de Jenkins" -ForegroundColor Red
    exit 1
}

Write-Host "Contenedor Jenkins encontrado: $jenkinsContainer" -ForegroundColor Green

# Instalar/actualizar plugins necesarios
Write-Host "`nInstalando/actualizando plugins..." -ForegroundColor Cyan

docker exec -u root $jenkinsContainer jenkins-plugin-cli --plugins `
    junit:latest `
    workflow-api:latest `
    workflow-step-api:latest `
    workflow-support:latest `
    workflow-cps:latest `
    workflow-job:latest `
    workflow-basic-steps:latest `
    workflow-durable-task-step:latest `
    jacoco:latest `
    structs:latest `
    plugin-util-api:latest

Write-Host "`nPlugins actualizados. Reiniciando Jenkins..." -ForegroundColor Cyan

# Reiniciar Jenkins
docker restart $jenkinsContainer

Write-Host ""
Write-Host "Jenkins reiniciado" -ForegroundColor Green
Write-Host "Espera unos 2-3 minutos para que Jenkins termine de iniciar" -ForegroundColor Yellow
Write-Host "Luego vuelve a ejecutar el pipeline" -ForegroundColor Yellow
