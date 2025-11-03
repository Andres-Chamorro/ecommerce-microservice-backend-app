# Script para instalar plugins faltantes que contienen jenkins/model/Tab

Write-Host "Instalando plugins faltantes para resolver jenkins/model/Tab..." -ForegroundColor Cyan

$jenkinsContainer = docker ps --filter "name=jenkins" --format "{{.Names}}" | Select-Object -First 1

if ([string]::IsNullOrEmpty($jenkinsContainer)) {
    Write-Host "Error: No se encontro el contenedor de Jenkins" -ForegroundColor Red
    exit 1
}

Write-Host "Instalando plugins de UI y display..." -ForegroundColor Cyan

# Instalar plugins relacionados con UI y tabs
docker exec -u root $jenkinsContainer jenkins-plugin-cli --plugins `
    display-url-api:latest `
    mailer:latest `
    matrix-project:latest `
    resource-disposer:latest `
    ws-cleanup:latest `
    ant:latest `
    gradle:latest `
    pipeline-stage-view:latest `
    pipeline-rest-api:latest `
    pipeline-graph-analysis:latest `
    pipeline-input-step:latest `
    pipeline-milestone-step:latest `
    pipeline-model-api:latest `
    pipeline-model-definition:latest `
    pipeline-model-extensions:latest `
    pipeline-stage-tags-metadata:latest

Write-Host ""
Write-Host "Plugins instalados. Reiniciando Jenkins..." -ForegroundColor Cyan

docker restart $jenkinsContainer

Write-Host ""
Write-Host "Jenkins reiniciado" -ForegroundColor Green
Write-Host "Espera 2-3 minutos y vuelve a intentar" -ForegroundColor Yellow
