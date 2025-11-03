# Script para reemplazar junit con archiveArtifacts en Jenkinsfiles de staging

Write-Host "Actualizando Jenkinsfiles de staging..." -ForegroundColor Cyan

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.staging"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar junit con archiveArtifacts
        $content = $content -replace "junit allowEmptyResults: true, testResults: 'tests/e2e/target/surefire-reports/\*\.xml'", "archiveArtifacts artifacts: 'tests/e2e/target/surefire-reports/**/*.xml', allowEmptyArchive: true"
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "  Actualizado $jenkinsfile" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Proceso completado" -ForegroundColor Green
Write-Host "Los Jenkinsfiles de staging ahora usan archiveArtifacts" -ForegroundColor Cyan
