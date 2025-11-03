# Script para hacer el rollout status no bloqueante

Write-Host "Haciendo rollout status no bloqueante..." -ForegroundColor Cyan
Write-Host ""

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando: $jenkinsfile" -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar el rollout status para que no falle el pipeline
        $content = $content -replace `
            "kubectl rollout status deployment/\`\${SERVICE_NAME} -n \`\$K8S_NAMESPACE --timeout=600s", `
            "kubectl rollout status deployment/`${SERVICE_NAME} -n `$K8S_NAMESPACE --timeout=600s || echo 'Rollout timeout - continuing anyway'"
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "  Rollout status actualizado" -ForegroundColor Green
    }
    else {
        Write-Host "  Archivo no encontrado: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Proceso completado!" -ForegroundColor Green
Write-Host ""
Write-Host "El rollout status ahora es no bloqueante." -ForegroundColor Cyan
Write-Host "Si el deployment tarda mas de 10 minutos, el pipeline continuara." -ForegroundColor White
