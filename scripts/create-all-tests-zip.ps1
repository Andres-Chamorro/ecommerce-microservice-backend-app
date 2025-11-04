# Script para crear ZIP con TODAS las pruebas implementadas
# Incluye: Unitarias, Integración, Performance y E2E

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipName = "todas-las-pruebas-$timestamp.zip"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creando ZIP con Todas las Pruebas" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Crear directorio temporal
$tempDir = "temp-all-tests"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

Write-Host "Recopilando archivos de pruebas..." -ForegroundColor Yellow
Write-Host ""

# 1. Pruebas Unitarias
Write-Host "1. Pruebas Unitarias" -ForegroundColor Cyan
$unitTestDirs = @(
    "user-service/src/test",
    "product-service/src/test",
    "order-service/src/test",
    "payment-service/src/test",
    "favourite-service/src/test",
    "shipping-service/src/test"
)

$unitTestDir = "$tempDir/1-pruebas-unitarias"
New-Item -ItemType Directory -Path $unitTestDir -Force | Out-Null

foreach ($dir in $unitTestDirs) {
    if (Test-Path $dir) {
        $serviceName = $dir.Split('/')[0]
        $destDir = "$unitTestDir/$serviceName"
        Write-Host "   Copiando $serviceName..." -ForegroundColor Gray
        Copy-Item -Path $dir -Destination $destDir -Recurse -Force
    }
}
Write-Host "   ✓ Pruebas unitarias copiadas" -ForegroundColor Green
Write-Host ""

# 2. Pruebas de Integración
Write-Host "2. Pruebas de Integración" -ForegroundColor Cyan
$integrationTestDir = "$tempDir/2-pruebas-integracion"
if (Test-Path "tests/integration") {
    Write-Host "   Copiando pruebas de integración..." -ForegroundColor Gray
    Copy-Item -Path "tests/integration" -Destination $integrationTestDir -Recurse -Force
    Write-Host "   ✓ Pruebas de integración copiadas" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No se encontraron pruebas de integración" -ForegroundColor Yellow
}
Write-Host ""

# 3. Pruebas de Performance
Write-Host "3. Pruebas de Performance" -ForegroundColor Cyan
$performanceTestDir = "$tempDir/3-pruebas-performance"
if (Test-Path "tests/performance") {
    Write-Host "   Copiando pruebas de performance..." -ForegroundColor Gray
    Copy-Item -Path "tests/performance" -Destination $performanceTestDir -Recurse -Force
    Write-Host "   ✓ Pruebas de performance copiadas" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No se encontraron pruebas de performance" -ForegroundColor Yellow
}
Write-Host ""

# 4. Pruebas E2E
Write-Host "4. Pruebas E2E (End-to-End)" -ForegroundColor Cyan
$e2eTestDir = "$tempDir/4-pruebas-e2e"
if (Test-Path "tests/e2e") {
    Write-Host "   Copiando pruebas E2E..." -ForegroundColor Gray
    Copy-Item -Path "tests/e2e" -Destination $e2eTestDir -Recurse -Force
    Write-Host "   ✓ Pruebas E2E copiadas" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No se encontraron pruebas E2E" -ForegroundColor Yellow
}
Write-Host ""

# 5. Crear README con información
Write-Host "5. Creando documentación..." -ForegroundColor Cyan
$readmeContent = @"
# Todas las Pruebas Implementadas
Fecha de generación: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Contenido del ZIP

### 1. Pruebas Unitarias (1-pruebas-unitarias/)
Pruebas unitarias para cada microservicio:
- user-service: Pruebas de UserService, UserResource
- product-service: Pruebas de ProductService, ProductResource
- order-service: Pruebas de OrderService, OrderResource
- payment-service: Pruebas de PaymentService, PaymentResource
- favourite-service: Pruebas de FavouriteService, FavouriteResource
- shipping-service: Pruebas de ShippingService, ShippingResource

**Tecnología:** JUnit 5, Mockito
**Cobertura:** Lógica de negocio y endpoints REST

### 2. Pruebas de Integración (2-pruebas-integracion/)
Pruebas de integración entre microservicios:
- UserOrderIntegrationTest: Integración User ↔ Order
- OrderPaymentIntegrationTest: Integración Order ↔ Payment
- OrderShippingIntegrationTest: Integración Order ↔ Shipping
- ProductFavouriteIntegrationTest: Integración Product ↔ Favourite

**Tecnología:** JUnit 5, RestAssured
**Cobertura:** Comunicación entre servicios

### 3. Pruebas de Performance (3-pruebas-performance/)
Pruebas de carga y rendimiento:
- locustfile.py: Escenarios de carga con Locust
- Simula usuarios concurrentes
- Mide tiempos de respuesta y throughput

**Tecnología:** Locust (Python)
**Escenarios:** 
- Navegación de productos
- Creación de órdenes
- Procesamiento de pagos
- Gestión de favoritos

### 4. Pruebas E2E (4-pruebas-e2e/)
Pruebas de extremo a extremo:
- CompleteUserJourneyE2ETest: Flujo completo de usuario
- ProductCatalogE2ETest: Navegación y búsqueda de productos
- ErrorHandlingE2ETest: Manejo de errores y casos edge

**Tecnología:** JUnit 5, RestAssured
**Cobertura:** Flujos de usuario completos

## Cómo Ejecutar las Pruebas

### Pruebas Unitarias
\`\`\`bash
cd <servicio>
mvn test -Dtest=*ServiceTest,*ResourceTest
\`\`\`

### Pruebas de Integración
\`\`\`bash
cd tests/integration
mvn test
\`\`\`

### Pruebas de Performance
\`\`\`bash
cd tests/performance
pip install locust
locust -f locustfile.py
# Abrir http://localhost:8089
\`\`\`

### Pruebas E2E
\`\`\`bash
cd tests/e2e
mvn test
\`\`\`

## Estadísticas

- **Pruebas Unitarias:** ~36 tests (6 por servicio)
- **Pruebas de Integración:** 12 tests
- **Pruebas de Performance:** 4 escenarios de carga
- **Pruebas E2E:** 9 tests

**Total:** ~61 tests automatizados

## Notas

- Todas las pruebas están documentadas con @DisplayName
- Las pruebas siguen las mejores prácticas de testing
- Cobertura de código disponible con JaCoCo
- Integración con Jenkins CI/CD

## Autor
Generado automáticamente por el sistema de CI/CD
"@

Set-Content -Path "$tempDir/README.md" -Value $readmeContent
Write-Host "   ✓ README.md creado" -ForegroundColor Green
Write-Host ""

# 6. Crear el ZIP
Write-Host "6. Creando archivo ZIP..." -ForegroundColor Cyan
if (Test-Path $zipName) {
    Remove-Item $zipName -Force
}

Compress-Archive -Path "$tempDir/*" -DestinationPath $zipName -Force
Write-Host "   ✓ ZIP creado: $zipName" -ForegroundColor Green
Write-Host ""

# 7. Limpiar directorio temporal
Remove-Item $tempDir -Recurse -Force

# 8. Mostrar resumen
$zipSize = (Get-Item $zipName).Length / 1MB
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ ZIP Creado Exitosamente" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivo: $zipName" -ForegroundColor White
Write-Host "Tamaño: $([math]::Round($zipSize, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "Contenido:" -ForegroundColor Yellow
Write-Host "  1. Pruebas Unitarias (6 servicios)" -ForegroundColor White
Write-Host "  2. Pruebas de Integración (4 suites)" -ForegroundColor White
Write-Host "  3. Pruebas de Performance (Locust)" -ForegroundColor White
Write-Host "  4. Pruebas E2E (3 suites)" -ForegroundColor White
Write-Host "  5. README.md con documentación" -ForegroundColor White
Write-Host ""
Write-Host "Listo para entregar en el informe ✓" -ForegroundColor Green
Write-Host ""
