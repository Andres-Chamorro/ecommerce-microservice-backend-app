# Script para actualizar la configuracion del Docker Registry en todos los Jenkinsfiles
# Este script reemplaza 'localhost:5000' con el registry de GCP

param(
    [string]$RegistryUrl = "us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry"
)

Write-Host "Actualizando Docker Registry en Jenkinsfiles..." -ForegroundColor Cyan
Write-Host "Registry URL: $RegistryUrl" -ForegroundColor Yellow
Write-Host ""

# Definir los microservicios
$services = @(
    'user-service',
    'product-service',
    'order-service',
    'payment-service',
    'favourite-service',
    'shipping-service'
)

# Definir los tipos de Jenkinsfile
$jenkinsfiles = @('Jenkinsfile.dev', 'Jenkinsfile.staging', 'Jenkinsfile.master')

$totalFiles = 0
$updatedFiles = 0

foreach ($service in $services) {
    Write-Host "Procesando $service..." -ForegroundColor Green
    
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        $totalFiles++
        
        if (Test-Path $filePath) {
            # Leer el contenido del archivo
            $content = Get-Content $filePath -Raw
            
            # Reemplazar localhost:5000 con el registry de GCP
            $oldPattern = "DOCKER_REGISTRY = 'localhost:5000'"
            $newPattern = "DOCKER_REGISTRY = '$RegistryUrl'"
            
            if ($content -match [regex]::Escape($oldPattern)) {
                $content = $content -replace [regex]::Escape($oldPattern), $newPattern
                
                # Guardar el archivo actualizado
                $content | Out-File -FilePath $filePath -Encoding UTF8 -NoNewline
                
                Write-Host "  OK $jenkinsfile actualizado" -ForegroundColor Green
                $updatedFiles++
            } else {
                Write-Host "  WARNING $jenkinsfile - Ya estaba actualizado o no encontro el patron" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ERROR $jenkinsfile - NO EXISTE" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resumen:" -ForegroundColor Cyan
Write-Host "  Total de archivos: $totalFiles" -ForegroundColor White
Write-Host "  Archivos actualizados: $updatedFiles" -ForegroundColor Green
Write-Host "  Registry configurado: $RegistryUrl" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Actualizacion completada!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Ejecutar: bash scripts/setup-gcr.sh" -ForegroundColor White
Write-Host "  2. Verificar que el registry funciona" -ForegroundColor White
Write-Host "  3. Configurar los pipelines en Jenkins" -ForegroundColor White
Write-Host ""
