# Script para reconstruir Jenkins con Locust instalado SIN PERDER DATOS
# Los datos de Jenkins están en un volumen de Docker y se mantienen seguros

Write-Host "🔄 Reconstruyendo imagen de Jenkins con Locust..." -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar que docker-compose.yml tiene el volumen configurado
Write-Host "📋 Paso 1: Verificando configuración de volúmenes..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    $composeContent = Get-Content "docker-compose.yml" -Raw
    if ($composeContent -match "jenkins_home") {
        Write-Host "✅ Volumen jenkins_home configurado correctamente" -ForegroundColor Green
    } else {
        Write-Host "⚠️  ADVERTENCIA: No se encontró volumen jenkins_home" -ForegroundColor Red
        Write-Host "   Tus datos podrían perderse. Verifica docker-compose.yml" -ForegroundColor Red
        $continue = Read-Host "¿Continuar de todos modos? (y/n)"
        if ($continue -ne "y") {
            Write-Host "❌ Operación cancelada" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "⚠️  docker-compose.yml no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Paso 2: Reconstruir la imagen de Jenkins
Write-Host "🔨 Paso 2: Reconstruyendo imagen de Jenkins..." -ForegroundColor Yellow
Write-Host "   Esto instalará Locust en la imagen..." -ForegroundColor Cyan
docker-compose build jenkins

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir la imagen" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Imagen reconstruida exitosamente" -ForegroundColor Green
Write-Host ""

# Paso 3: Reiniciar el contenedor de Jenkins
Write-Host "🔄 Paso 3: Reiniciando contenedor de Jenkins..." -ForegroundColor Yellow
Write-Host "   Tus datos están seguros en el volumen jenkins_home" -ForegroundColor Cyan
docker-compose up -d jenkins

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al reiniciar Jenkins" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Jenkins reiniciado exitosamente" -ForegroundColor Green
Write-Host ""

# Paso 4: Esperar a que Jenkins esté listo
Write-Host "⏳ Paso 4: Esperando a que Jenkins esté listo..." -ForegroundColor Yellow
Write-Host "   Esto puede tomar 30-60 segundos..." -ForegroundColor Cyan

$maxAttempts = 30
$attempt = 0
$jenkinsReady = $false

while ($attempt -lt $maxAttempts -and -not $jenkinsReady) {
    Start-Sleep -Seconds 2
    $attempt++
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/login" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $jenkinsReady = $true
        }
    } catch {
        Write-Host "." -NoNewline
    }
}

Write-Host ""

if ($jenkinsReady) {
    Write-Host "✅ Jenkins está listo y funcionando" -ForegroundColor Green
} else {
    Write-Host "⚠️  Jenkins está tardando más de lo esperado" -ForegroundColor Yellow
    Write-Host "   Verifica manualmente en http://localhost:8080" -ForegroundColor Cyan
}

Write-Host ""

# Paso 5: Verificar que Locust está instalado
Write-Host "🔍 Paso 5: Verificando instalación de Locust..." -ForegroundColor Yellow
$locustCheck = docker-compose exec -T jenkins locust --version 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Locust instalado correctamente: $locustCheck" -ForegroundColor Green
} else {
    Write-Host "⚠️  No se pudo verificar Locust (Jenkins podría estar iniciando)" -ForegroundColor Yellow
    Write-Host "   Verifica manualmente con: docker-compose exec jenkins locust --version" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resumen:" -ForegroundColor Yellow
Write-Host "   - Imagen de Jenkins reconstruida con Locust" -ForegroundColor Green
Write-Host "   - Contenedor reiniciado" -ForegroundColor Green
Write-Host "   - Datos preservados (jobs, configuraciones, credenciales)" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Accede a Jenkins en: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Verifica que tus jobs siguen ahi" -ForegroundColor White
Write-Host "   2. Ejecuta un pipeline de staging para probar Locust" -ForegroundColor White
Write-Host "   3. Las pruebas de performance ahora deberian funcionar" -ForegroundColor White
Write-Host ""
