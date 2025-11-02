# Script para envolver llamadas a junit en try-catch

Write-Host "Envolviendo llamadas a junit en try-catch..." -ForegroundColor Cyan

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
        
        # Reemplazar el bloque post always con junit
        $pattern = "            post \{\s+always \{\s+junit allowEmptyResults: true, testResults: '$service/target/surefire-reports/\*\.xml'\s+\}\s+\}"
        
        $replacement = @"
            post {
                always {
                    script {
                        try {
                            junit allowEmptyResults: true, testResults: '$service/target/surefire-reports/*.xml'
                        } catch (Exception e) {
                            echo "WARNING: No se pudieron procesar resultados JUnit: `${e.message}"
                            echo "Los tests se ejecutaron pero no se generaron reportes visuales"
                        }
                    }
                }
            }
"@
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "  Actualizado $jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "  No se encontro el patron en $jenkinsfile" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "Proceso completado" -ForegroundColor Green
Write-Host "Ahora los pipelines no fallaran si hay problemas con el plugin JUnit" -ForegroundColor Cyan
