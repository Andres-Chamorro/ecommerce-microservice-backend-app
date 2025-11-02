# Script para cambiar junit por publishHTML como alternativa temporal

Write-Host "Modificando Jenkinsfiles para usar alternativa a junit..." -ForegroundColor Cyan

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar el bloque post de Unit Tests para que sea opcional
        $oldPattern = @"
            post {
                always {
                    junit allowEmptyResults: true, testResults: '$service/target/surefire-reports/\*\.xml'
                }
            }
"@

        $newPattern = @"
            post {
                always {
                    script {
                        try {
                            junit allowEmptyResults: true, testResults: '$service/target/surefire-reports/*.xml'
                        } catch (Exception e) {
                            echo "WARNING: No se pudo procesar resultados JUnit: `${e.message}"
                        }
                    }
                }
            }
"@

        $content = $content -replace [regex]::Escape($oldPattern), $newPattern
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "  Actualizado $jenkinsfile" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Jenkinsfiles actualizados con manejo de errores para junit" -ForegroundColor Green
