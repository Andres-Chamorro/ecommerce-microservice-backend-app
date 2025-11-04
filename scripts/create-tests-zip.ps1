# Script para crear un ZIP con todas las pruebas implementadas para el taller

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipName = "pruebas_implementadas_$timestamp.zip"

Write-Host "📦 Creando ZIP con todas las pruebas implementadas..." -ForegroundColor Cyan
Write-Host ""

# Crear carpeta temporal para organizar las pruebas
$tempDir = "temp_tests_export"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copiar pruebas unitarias de cada servicio
Write-Host "📋 Copiando pruebas unitarias..." -ForegroundColor Yellow
$services = @("user-service", "product-service", "order-service", "payment-service", "favourite-service", "shipping-service")

foreach ($service in $services) {
    $testPath = "$service/src/test"
    if (Test-Path $testPath) {
        $destPath = "$tempDir/unit-tests/$service"
        Copy-Item -Path $testPath -Destination $destPath -Recurse
        Write-Host "  ✅ $service" -ForegroundColor Green
    }
}

# Copiar pruebas de integración
Write-Host ""
Write-Host "📋 Copiando pruebas de integración..." -ForegroundColor Yellow
if (Test-Path "tests/integration") {
    Copy-Item -Path "tests/integration" -Destination "$tempDir/integration-tests" -Recurse
    Write-Host "  ✅ Pruebas de integración" -ForegroundColor Green
}

# Copiar pruebas E2E
Write-Host ""
Write-Host "📋 Copiando pruebas E2E..." -ForegroundColor Yellow
if (Test-Path "tests/e2e") {
    Copy-Item -Path "tests/e2e" -Destination "$tempDir/e2e-tests" -Recurse
    Write-Host "  ✅ Pruebas E2E" -ForegroundColor Green
}

# Copiar pruebas de rendimiento
Write-Host ""
Write-Host "📋 Copiando pruebas de rendimiento..." -ForegroundColor Yellow
if (Test-Path "tests/performance") {
    Copy-Item -Path "tests/performance" -Destination "$tempDir/performance-tests" -Recurse
    Write-Host "  ✅ Pruebas de rendimiento (Locust)" -ForegroundColor Green
}

# Crear archivo README con información
$readmeContent = @"
# Pruebas Implementadas - Taller de Microservicios

Fecha de generación: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Estructura del ZIP

### 1. Pruebas Unitarias (unit-tests/)
Pruebas unitarias para cada microservicio:
- user-service/
- product-service/
- order-service/
- payment-service/
- favourite-service/
- shipping-service/

Tecnología: JUnit 5 + Mockito
Cobertura: Servicios, repositorios y controladores

### 2. Pruebas de Integración (integration-tests/)
Pruebas que validan la comunicación entre microservicios:
- UserOrderIntegrationTest: User Service ↔ Order Service
- OrderPaymentIntegrationTest: Order Service ↔ Payment Service
- OrderShippingIntegrationTest: Order Service ↔ Shipping Service
- ProductFavouriteIntegrationTest: Product Service ↔ Favourite Service

Tecnología: REST Assured + JUnit 5
Configuración: URLs configurables via variables de entorno

### 3. Pruebas E2E (e2e-tests/)
Pruebas de extremo a extremo que simulan flujos de usuario completos:
- CompleteUserJourneyE2ETest: Flujo completo de compra
- ProductCatalogE2ETest: Navegación y búsqueda de productos
- ErrorHandlingE2ETest: Manejo de errores y casos edge

Tecnología: REST Assured + JUnit 5
Alcance: Flujos completos de usuario

### 4. Pruebas de Rendimiento (performance-tests/)
Pruebas de carga y estrés usando Locust:
- locustfile.py: Escenarios de carga para todos los servicios

Tecnología: Locust (Python)
Métricas: Throughput, latencia, tasa de error

## Ejecución de Pruebas

### Pruebas Unitarias
```bash
cd <servicio>
mvn test
```

### Pruebas de Integración
```bash
cd tests/integration
mvn test
```

### Pruebas E2E
```bash
cd tests/e2e
mvn test
```

### Pruebas de Rendimiento
```bash
cd tests/performance
locust -f locustfile.py
```

## Configuración

Las pruebas de integración y E2E requieren que los servicios estén desplegados.
Se pueden configurar las URLs mediante variables de entorno:
- USER_SERVICE_URL
- ORDER_SERVICE_URL
- PAYMENT_SERVICE_URL
- PRODUCT_SERVICE_URL
- SHIPPING_SERVICE_URL
- FAVOURITE_SERVICE_URL

## Integración con CI/CD

Todas las pruebas están integradas en los pipelines de Jenkins:
- Dev: Pruebas unitarias + integración
- Staging: Pruebas unitarias + integración + E2E + rendimiento
- Master/Production: Pruebas unitarias + smoke tests

"@

Set-Content -Path "$tempDir/README.md" -Value $readmeContent -Encoding UTF8
Write-Host ""
Write-Host "  ✅ README.md creado" -ForegroundColor Green

# Crear el ZIP
Write-Host ""
Write-Host "🗜️  Comprimiendo archivos..." -ForegroundColor Yellow
Compress-Archive -Path "$tempDir/*" -DestinationPath $zipName -Force

# Limpiar carpeta temporal
Remove-Item -Recurse -Force $tempDir

Write-Host ""
Write-Host "✅ ZIP creado exitosamente: $zipName" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Contenido del ZIP:" -ForegroundColor Cyan
Write-Host "  - Pruebas unitarias (6 servicios)" -ForegroundColor White
Write-Host "  - Pruebas de integración (4 suites)" -ForegroundColor White
Write-Host "  - Pruebas E2E (3 suites)" -ForegroundColor White
Write-Host "  - Pruebas de rendimiento (Locust)" -ForegroundColor White
Write-Host "  - README.md con documentación" -ForegroundColor White
Write-Host ""
Write-Host "📍 Ubicación: $(Get-Location)\$zipName" -ForegroundColor Cyan
