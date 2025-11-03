# Script para corregir las rutas de pruebas en staging

Write-Host "🔧 Corrigiendo rutas de pruebas en Jenkinsfiles de staging..." -ForegroundColor Cyan

$services = @(
    "shipping-service",
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📝 Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar el stage E2E completo para usar Maven desde la raíz
        $oldE2E = @'
                        # Ejecutar pruebas E2E si existen
                        if [ -d tests/e2e ]; then
                            cd tests/e2e
                            mvn test -Dtest=*E2ETest -Dservice.url=http://$SERVICE_URL:${SERVICE_PORT} || echo "⚠️ Algunas pruebas E2E fallaron"
                        else
                            echo "ℹ️ No hay pruebas E2E configuradas"
                        fi
'@

        $newE2E = @'
                        # Ejecutar pruebas E2E con Maven
                        echo "🧪 Ejecutando pruebas E2E..."
                        mvn test -Dtest=*E2ETest,*IntegrationTest -Dservice.url=http://$SERVICE_URL:${SERVICE_PORT} || echo "⚠️ Algunas pruebas E2E fallaron"
'@

        $content = $content -replace [regex]::Escape($oldE2E), $newE2E
        
        # Actualizar la ruta de archiveArtifacts para E2E
        $content = $content -replace `
            "if \(fileExists\('tests/e2e/target/surefire-reports'\)\)", `
            "if (fileExists('target/surefire-reports'))"
        
        $content = $content -replace `
            "archiveArtifacts artifacts: 'tests/e2e/target/surefire-reports/\*\*/\*\.xml'", `
            "archiveArtifacts artifacts: 'target/surefire-reports/**/*.xml'"
        
        # Actualizar Performance tests para buscar en la raíz
        $content = $content -replace `
            "if \[ -f tests/performance/locustfile\.py \]; then", `
            "if [ -f src/test/performance/locustfile.py ]; then"
        
        $content = $content -replace `
            "locust -f tests/performance/locustfile\.py", `
            "locust -f src/test/performance/locustfile.py"
        
        $content = $content -replace `
            "--html=tests/performance/locust-report\.html", `
            "--html=target/locust-report.html"
        
        $content = $content -replace `
            "echo ""✅ Reporte generado en tests/performance/locust-report\.html""", `
            "echo ""✅ Reporte generado en target/locust-report.html"""
        
        $content = $content -replace `
            "if \(fileExists\('tests/performance/locust-report\.html'\)\)", `
            "if (fileExists('target/locust-report.html'))"
        
        $content = $content -replace `
            "archiveArtifacts artifacts: 'tests/performance/locust-report\.html'", `
            "archiveArtifacts artifacts: 'target/locust-report.html'"
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "  ✅ $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ Correcciones aplicadas:" -ForegroundColor Green
Write-Host "  1. ✅ Pruebas E2E ejecutadas desde raíz con Maven" -ForegroundColor Green
Write-Host "  2. ✅ Reportes buscados en target/surefire-reports" -ForegroundColor Green
Write-Host "  3. ✅ Performance tests en src/test/performance" -ForegroundColor Green
Write-Host "  4. ✅ Reportes Locust en target/locust-report.html" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Ejecuta el pipeline de staging nuevamente" -ForegroundColor Cyan
