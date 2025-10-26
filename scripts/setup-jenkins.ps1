# Script de PowerShell para configurar Jenkins en Windows

Write-Host "🚀 Configurando Jenkins para el proyecto..." -ForegroundColor Green
Write-Host ""

# Verificar que Docker Desktop esté corriendo
Write-Host "📦 Verificando Docker Desktop..." -ForegroundColor Yellow
$dockerRunning = docker ps 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Desktop no está corriendo" -ForegroundColor Red
    Write-Host "Por favor, inicia Docker Desktop y vuelve a ejecutar este script" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Docker Desktop está corriendo" -ForegroundColor Green
Write-Host ""

# Levantar Jenkins
Write-Host "🐳 Levantando Jenkins con Docker Compose..." -ForegroundColor Yellow
docker-compose -f docker-compose.jenkins.yml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al levantar Jenkins" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Jenkins iniciado correctamente" -ForegroundColor Green
Write-Host ""

# Esperar a que Jenkins inicie
Write-Host "⏳ Esperando a que Jenkins inicie completamente (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Obtener la contraseña inicial
Write-Host ""
Write-Host "🔑 Contraseña inicial de Jenkins:" -ForegroundColor Cyan
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
Write-Host ""

# Mostrar información
Write-Host "✅ Jenkins está corriendo en: http://localhost:8079" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Abre http://localhost:8079 en tu navegador" -ForegroundColor White
Write-Host "2. Usa la contraseña mostrada arriba" -ForegroundColor White
Write-Host "3. Selecciona 'Install suggested plugins'" -ForegroundColor White
Write-Host "4. Crea un usuario admin" -ForegroundColor White
Write-Host "5. Sigue la guía en docs/JENKINS-SETUP.md" -ForegroundColor White
Write-Host ""
Write-Host "📖 Lee la documentación completa en: docs/JENKINS-SETUP.md" -ForegroundColor Cyan
Write-Host ""

# Abrir Jenkins en el navegador
Write-Host "🌐 Abriendo Jenkins en el navegador..." -ForegroundColor Yellow
Start-Process "http://localhost:8079"
