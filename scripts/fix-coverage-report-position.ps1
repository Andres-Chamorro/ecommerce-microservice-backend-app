# Script para mover el stage de Code Coverage Report al final (despues de Integration Tests)
# y eliminar duplicados

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Patron para encontrar el primer stage de Code Coverage Report (despues de Unit Tests)
        $firstCoveragePattern = "(?s)(        }\s+)(        stage\('Code Coverage Report'\) \{.*?            \}\s+        \}\s+)(        stage\('Build Docker Image'\))"
        
        # Patron para encontrar el segundo stage de Code Coverage Report (duplicado al final)
        $secondCoveragePattern = "(?s)(        \}        \s+)(        stage\('Code Coverage Report'\) \{.*?            \}\s+        \}\s+)(\s+    \})"
        
        # Primero, extraer el contenido del stage de cobertura
        if ($content -match $firstCoveragePattern) {
            $coverageStage = $matches[2]
            
            # Actualizar el mensaje del stage para indicar que incluye ambas pruebas
            $coverageStage = $coverageStage -replace "Generando reporte de cobertura de codigo\.\.\.", "Generando reporte de cobertura de codigo (unitarias + integracion)..."
            
            # Eliminar el primer stage de Code Coverage Report
            $content = $content -replace $firstCoveragePattern, '$1$3'
            
            # Eliminar el segundo stage de Code Coverage Report si existe
            $content = $content -replace $secondCoveragePattern, '$1$3'
            
            # Agregar el stage al final, antes del cierre de stages
            $integrationTestsEnd = "(?s)(        stage\('Integration Tests'\) \{.*?        \})(        \s+    \})"
            
            if ($content -match $integrationTestsEnd) {
                $content = $content -replace $integrationTestsEnd, "`$1`n        `n$coverageStage`$2"
            }
            
            # Guardar el archivo
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "✓ $jenkinsfile actualizado correctamente" -ForegroundColor Green
        } else {
            Write-Host "⚠ No se encontro el patron esperado en $jenkinsfile" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ No se encontro $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host "`n✓ Proceso completado" -ForegroundColor Green
Write-Host "El stage 'Code Coverage Report' ahora se ejecuta despues de 'Integration Tests' en todos los servicios" -ForegroundColor Cyan
