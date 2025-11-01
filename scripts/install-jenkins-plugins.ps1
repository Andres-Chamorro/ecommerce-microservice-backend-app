Write-Host "Instalando plugins de Jenkins..." -ForegroundColor Cyan

# Lista de plugins necesarios
$plugins = @(
    "jacoco",                    # JaCoCo Code Coverage
    "htmlpublisher",             # HTML Publisher para reportes HTML
    "junit",                     # JUnit Plugin (ya debería estar)
    "workflow-aggregator",       # Pipeline Plugin (ya debería estar)
    "git",                       # Git Plugin (ya debería estar)
    "docker-workflow",           # Docker Pipeline Plugin
    "kubernetes",                # Kubernetes Plugin
    "kubernetes-cli"             # Kubernetes CLI Plugin
)

Write-Host "`nPlugins a instalar:" -ForegroundColor Yellow
$plugins | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }

Write-Host "`nInstalando plugins..." -ForegroundColor Yellow

foreach ($plugin in $plugins) {
    Write-Host "Instalando $plugin..." -ForegroundColor Cyan
    
    # Instalar plugin usando Jenkins CLI
    docker exec jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin $plugin -restart
}

Write-Host "`nEsperando a que Jenkins reinicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`nVerificando que Jenkins este activo..." -ForegroundColor Yellow
$maxAttempts = 10
$attempt = 0
$jenkinsReady = $false

while ($attempt -lt $maxAttempts -and -not $jenkinsReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8079" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            $jenkinsReady = $true
            Write-Host "Jenkins esta activo" -ForegroundColor Green
        }
    } catch {
        $attempt++
        Write-Host "Intento $attempt de $maxAttempts..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
}

if ($jenkinsReady) {
    Write-Host "`nPlugins instalados correctamente" -ForegroundColor Green
    Write-Host "Jenkins esta listo en: http://localhost:8079" -ForegroundColor Cyan
} else {
    Write-Host "`nWARNING: Jenkins puede estar reiniciando aun" -ForegroundColor Yellow
    Write-Host "Espera unos minutos y verifica en http://localhost:8079" -ForegroundColor Cyan
}
