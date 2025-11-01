Write-Host "Instalando plugins de Jenkins..." -ForegroundColor Cyan

$plugins = @(
    "jacoco",
    "htmlpublisher",
    "junit",
    "workflow-aggregator",
    "git",
    "docker-workflow",
    "kubernetes",
    "kubernetes-cli"
)

Write-Host "`nPlugins a instalar:" -ForegroundColor Yellow
$plugins | ForEach-Object { Write-Host "  - $_" }

Write-Host "`nDescargando e instalando plugins..." -ForegroundColor Yellow

foreach ($plugin in $plugins) {
    Write-Host "Instalando $plugin..." -ForegroundColor Cyan
    docker exec jenkins bash -c "curl -L -o /var/jenkins_home/plugins/$plugin.hpi https://updates.jenkins.io/latest/$plugin.hpi 2>/dev/null"
}

Write-Host "`nPlugins descargados" -ForegroundColor Green
Write-Host "Reiniciando Jenkins..." -ForegroundColor Yellow

docker restart jenkins

Write-Host "`nEsperando a que Jenkins reinicie (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

Write-Host "`nJenkins reiniciado" -ForegroundColor Green
Write-Host "Accede a Jenkins en: http://localhost:8079" -ForegroundColor Cyan
Write-Host "`nVerifica los plugins instalados en:" -ForegroundColor Yellow
Write-Host "  Manage Jenkins > Manage Plugins > Installed" -ForegroundColor White
