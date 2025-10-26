# Script para ejecutar todas las pruebas del proyecto

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Ejecutando Suite Completa de Pruebas" -ForegroundColor Cyan
Write-Host "Ecommerce Microservices - 83 Pruebas" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$startTime = Get-Date

# Funcion para mostrar resultados
function Show-TestResult {
    param(
        [string]$TestName,
        [int]$ExitCode
    )
    if ($ExitCode -eq 0) {
        Write-Host "  OK $TestName - PASSED" -ForegroundColor Green
        return 1
    } else {
        Write-Host "  FAIL $TestName - FAILED" -ForegroundColor Red
        return 0
    }
}

# Contadores
$totalPassed = 0
$totalFailed = 0

# 1. Pruebas Unitarias (48 pruebas)
Write-Host '[1/4] Ejecutando Pruebas Unitarias (48 pruebas)...' -ForegroundColor Yellow
Write-Host '---------------------------------------------------' -ForegroundColor Yellow
Write-Host ''

# User Service (12 pruebas)
Write-Host 'User Service (12 pruebas):' -ForegroundColor Cyan
Set-Location user-service

mvn test -Dtest=UserServiceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'UserServiceTest (6 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

mvn test -Dtest=UserResourceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'UserResourceTest (6 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..
Write-Host ''

# Product Service (13 pruebas)
Write-Host 'Product Service (13 pruebas):' -ForegroundColor Cyan
Set-Location product-service

mvn test -Dtest=ProductServiceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'ProductServiceTest (7 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

mvn test -Dtest=ProductResourceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'ProductResourceTest (6 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..
Write-Host ''

# Order Service (7 pruebas)
Write-Host 'Order Service (7 pruebas):' -ForegroundColor Cyan
Set-Location order-service

mvn test -Dtest=OrderServiceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'OrderServiceTest (7 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..
Write-Host ''

# Payment Service (8 pruebas)
Write-Host 'Payment Service (8 pruebas):' -ForegroundColor Cyan
Set-Location payment-service

mvn test -Dtest=PaymentServiceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'PaymentServiceTest (8 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..
Write-Host ''

# Shipping Service (6 pruebas)
Write-Host 'Shipping Service (6 pruebas):' -ForegroundColor Cyan
Set-Location shipping-service

mvn test -Dtest=ShippingServiceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'ShippingServiceTest (6 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..
Write-Host ''

# Favourite Service (8 pruebas)
Write-Host 'Favourite Service (8 pruebas):' -ForegroundColor Cyan
Set-Location favourite-service

mvn test -Dtest=FavouriteServiceTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'FavouriteServiceTest (8 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..
Write-Host ''

# 2. Pruebas de Integración (12 pruebas)
Write-Host '[2/4] Ejecutando Pruebas de Integración (12 pruebas)...' -ForegroundColor Yellow
Write-Host '--------------------------------------------------------' -ForegroundColor Yellow
Write-Host ''

Write-Host 'Verificando que los servicios estén corriendo...' -ForegroundColor Cyan
kubectl get pods -n ecommerce-dev 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host '  ⚠ Kubernetes no disponible. Algunas pruebas pueden fallar.' -ForegroundColor Yellow
}
Write-Host ''

Set-Location tests\integration

Write-Host 'User-Order Integration (3 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=UserOrderIntegrationTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'UserOrderIntegrationTest (3 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Write-Host 'Order-Payment Integration (3 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=OrderPaymentIntegrationTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'OrderPaymentIntegrationTest (3 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Write-Host 'Product-Favourite Integration (3 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=ProductFavouriteIntegrationTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'ProductFavouriteIntegrationTest (3 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Write-Host 'Order-Shipping Integration (3 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=OrderShippingIntegrationTest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'OrderShippingIntegrationTest (3 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..\..
Write-Host ''

# 3. Pruebas E2E (23 pruebas)
Write-Host '[3/4] Ejecutando Pruebas End-to-End (23 pruebas)...' -ForegroundColor Yellow
Write-Host '----------------------------------------------------' -ForegroundColor Yellow
Write-Host ''

Set-Location tests\e2e

Write-Host 'Complete User Journey (8 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=CompleteUserJourneyE2ETest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'CompleteUserJourneyE2ETest (8 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Write-Host 'Product Catalog (3 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=ProductCatalogE2ETest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'ProductCatalogE2ETest (3 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Write-Host 'Admin Operations (6 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=AdminOperationsE2ETest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'AdminOperationsE2ETest (6 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Write-Host 'Error Handling (6 pruebas):' -ForegroundColor Cyan
mvn test -Dtest=ErrorHandlingE2ETest -q
$result = $LASTEXITCODE
$totalPassed += Show-TestResult 'ErrorHandlingE2ETest (6 pruebas)' $result
if ($result -ne 0) { $totalFailed++ }

Set-Location ..\..
Write-Host ''

# 4. Pruebas de Rendimiento (Locust)
Write-Host '[4/4] Preparando Pruebas de Rendimiento (Locust)...' -ForegroundColor Yellow
Write-Host '-----------------------------------------------------' -ForegroundColor Yellow
Write-Host ''

Write-Host "Verificando instalación de Locust..." -ForegroundColor Cyan
python -m pip show locust >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ⚠ Locust no está instalado. Instalando..." -ForegroundColor Yellow
    Set-Location tests\performance
    pip install -r requirements.txt -q
    Set-Location ..\..
    Write-Host "  ✓ Locust instalado correctamente" -ForegroundColor Green
} else {
    Write-Host "  ✓ Locust ya está instalado" -ForegroundColor Green
}

Write-Host ""
Write-Host "Para ejecutar pruebas de rendimiento:" -ForegroundColor Cyan
Write-Host "  cd tests\performance" -ForegroundColor White
Write-Host "  locust -f locustfile.py --host=http://localhost:8080" -ForegroundColor White
Write-Host "  Luego abre: http://localhost:8089" -ForegroundColor White
Write-Host ""

# Calcular tiempo total
$endTime = Get-Date
$duration = $endTime - $startTime
$totalSeconds = [math]::Round($duration.TotalSeconds, 2)

# Resumen Final
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Resumen de Resultados" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pruebas Unitarias:" -ForegroundColor Yellow
Write-Host "  - User Service: 12 pruebas" -ForegroundColor White
Write-Host "  - Product Service: 13 pruebas" -ForegroundColor White
Write-Host "  - Order Service: 7 pruebas" -ForegroundColor White
Write-Host "  - Payment Service: 8 pruebas" -ForegroundColor White
Write-Host "  - Shipping Service: 6 pruebas" -ForegroundColor White
Write-Host "  - Favourite Service: 8 pruebas" -ForegroundColor White
Write-Host "  Total: 48 pruebas unitarias" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pruebas de Integración:" -ForegroundColor Yellow
Write-Host "  - User-Order: 3 pruebas" -ForegroundColor White
Write-Host "  - Order-Payment: 3 pruebas" -ForegroundColor White
Write-Host "  - Product-Favourite: 3 pruebas" -ForegroundColor White
Write-Host "  - Order-Shipping: 3 pruebas" -ForegroundColor White
Write-Host "  Total: 12 pruebas de integración" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pruebas E2E:" -ForegroundColor Yellow
Write-Host "  - Complete User Journey: 8 pruebas" -ForegroundColor White
Write-Host "  - Product Catalog: 3 pruebas" -ForegroundColor White
Write-Host "  - Admin Operations: 6 pruebas" -ForegroundColor White
Write-Host "  - Error Handling: 6 pruebas" -ForegroundColor White
Write-Host "  Total: 23 pruebas E2E" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pruebas de Rendimiento:" -ForegroundColor Yellow
Write-Host "  - Locust: Configurado y listo" -ForegroundColor White
Write-Host ""

$totalTestSuites = $totalPassed + $totalFailed
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Suites ejecutadas: $totalTestSuites" -ForegroundColor White
Write-Host "Suites exitosas: $totalPassed" -ForegroundColor Green
Write-Host "Suites fallidas: $totalFailed" -ForegroundColor $(if ($totalFailed -eq 0) { "Green" } else { "Red" })
Write-Host "Tiempo total: $totalSeconds segundos" -ForegroundColor White
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if ($totalFailed -eq 0) {
    Write-Host "EXITO - Todas las pruebas pasaron exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Total de pruebas individuales: 83" -ForegroundColor Cyan
    Write-Host "  - 48 pruebas unitarias OK" -ForegroundColor Green
    Write-Host "  - 12 pruebas de integracion OK" -ForegroundColor Green
    Write-Host "  - 23 pruebas E2E OK" -ForegroundColor Green
} else {
    Write-Host "ADVERTENCIA - Algunas pruebas fallaron. Revisa los logs arriba." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Reportes generados en:" -ForegroundColor Cyan
Write-Host "  - */target/surefire-reports/ (Reportes de pruebas)" -ForegroundColor White
Write-Host "  - */target/site/jacoco/ (Cobertura de código)" -ForegroundColor White
Write-Host ""
Write-Host "Para ver reportes detallados:" -ForegroundColor Cyan
Write-Host "  mvn surefire-report:report" -ForegroundColor White
Write-Host "  mvn jacoco:report" -ForegroundColor White
Write-Host ""
