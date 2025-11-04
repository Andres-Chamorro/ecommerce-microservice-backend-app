# Script simple para crear ZIP con todas las pruebas

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipName = "todas-las-pruebas-$timestamp.zip"

Write-Host "Creando ZIP con todas las pruebas..." -ForegroundColor Cyan
Write-Host ""

# Crear directorio temporal
$tempDir = "temp-all-tests"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# 1. Pruebas Unitarias
Write-Host "1. Copiando pruebas unitarias..." -ForegroundColor Yellow
$unitTestDir = "$tempDir/1-pruebas-unitarias"
New-Item -ItemType Directory -Path $unitTestDir -Force | Out-Null

$services = @("user-service", "product-service", "order-service", "payment-service", "favourite-service", "shipping-service")
foreach ($svc in $services) {
    $testPath = "$svc/src/test"
    if (Test-Path $testPath) {
        $destDir = "$unitTestDir/$svc"
        Copy-Item -Path $testPath -Destination $destDir -Recurse -Force
        Write-Host "   - $svc copiado" -ForegroundColor Gray
    }
}

# 2. Pruebas de Integracion
Write-Host "2. Copiando pruebas de integracion..." -ForegroundColor Yellow
if (Test-Path "tests/integration") {
    Copy-Item -Path "tests/integration" -Destination "$tempDir/2-pruebas-integracion" -Recurse -Force
    Write-Host "   - Integracion copiada" -ForegroundColor Gray
}

# 3. Pruebas de Performance
Write-Host "3. Copiando pruebas de performance..." -ForegroundColor Yellow
if (Test-Path "tests/performance") {
    Copy-Item -Path "tests/performance" -Destination "$tempDir/3-pruebas-performance" -Recurse -Force
    Write-Host "   - Performance copiada" -ForegroundColor Gray
}

# 4. Pruebas E2E
Write-Host "4. Copiando pruebas E2E..." -ForegroundColor Yellow
if (Test-Path "tests/e2e") {
    Copy-Item -Path "tests/e2e" -Destination "$tempDir/4-pruebas-e2e" -Recurse -Force
    Write-Host "   - E2E copiada" -ForegroundColor Gray
}

# 5. Crear README
Write-Host "5. Creando README..." -ForegroundColor Yellow
$readme = @"
# Todas las Pruebas Implementadas

Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Contenido

1. Pruebas Unitarias (6 servicios)
   - user-service
   - product-service
   - order-service
   - payment-service
   - favourite-service
   - shipping-service

2. Pruebas de Integracion (4 suites)
   - UserOrderIntegrationTest
   - OrderPaymentIntegrationTest
   - OrderShippingIntegrationTest
   - ProductFavouriteIntegrationTest

3. Pruebas de Performance
   - locustfile.py (Locust)

4. Pruebas E2E (3 suites)
   - CompleteUserJourneyE2ETest
   - ProductCatalogE2ETest
   - ErrorHandlingE2ETest

## Estadisticas

- Pruebas Unitarias: ~36 tests
- Pruebas de Integracion: 12 tests
- Pruebas de Performance: 4 escenarios
- Pruebas E2E: 9 tests

Total: ~61 tests automatizados

## Como Ejecutar

### Pruebas Unitarias
cd <servicio>
mvn test

### Pruebas de Integracion
cd tests/integration
mvn test

### Pruebas de Performance
cd tests/performance
pip install locust
locust -f locustfile.py

### Pruebas E2E
cd tests/e2e
mvn test
"@

Set-Content -Path "$tempDir/README.md" -Value $readme

# 6. Crear ZIP
Write-Host "6. Creando archivo ZIP..." -ForegroundColor Yellow
if (Test-Path $zipName) {
    Remove-Item $zipName -Force
}

Compress-Archive -Path "$tempDir/*" -DestinationPath $zipName -Force

# 7. Limpiar
Remove-Item $tempDir -Recurse -Force

# 8. Resumen
$zipSize = (Get-Item $zipName).Length / 1MB
Write-Host ""
Write-Host "ZIP creado exitosamente" -ForegroundColor Green
Write-Host "Archivo: $zipName" -ForegroundColor White
Write-Host "Tamano: $([math]::Round($zipSize, 2)) MB" -ForegroundColor White
Write-Host ""
