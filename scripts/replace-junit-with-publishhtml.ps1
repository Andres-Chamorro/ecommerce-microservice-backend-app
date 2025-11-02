# Script para reemplazar junit con publishHTML para reportes visuales

Write-Host "Reemplazando junit con publishHTML en los Jenkinsfiles..." -ForegroundColor Cyan

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
        
        # Reemplazar el bloque post con junit por publishHTML
        $oldPattern = @"
            post \{
                always \{
                    script \{
                        try \{
                            junit allowEmptyResults: true, testResults: '$service/target/surefire-reports/\*\.xml'
                        \} catch \(Exception e\) \{
                            echo "WARNING: No se pudieron procesar resultados JUnit: \`$\{e\.message\}"
                            echo "Los tests se ejecutaron pero no se generaron reportes visuales"
                        \}
                    \}
                \}
            \}
"@

        $newPattern = @"
            post {
                always {
                    publishHTML([
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '$service/target/surefire-reports',
                        reportFiles: 'index.html',
                        reportName: 'Test Report',
                        reportTitles: 'Unit Tests'
                    ])
                }
            }
"@
        
        $content = $content -replace $oldPattern, $newPattern
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "  Actualizado $jenkinsfile" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Proceso completado" -ForegroundColor Green
Write-Host "Ahora los reportes se publicaran como HTML en Jenkins" -ForegroundColor Cyan
Write-Host "Podras ver los reportes en la pagina del build" -ForegroundColor Yellow
