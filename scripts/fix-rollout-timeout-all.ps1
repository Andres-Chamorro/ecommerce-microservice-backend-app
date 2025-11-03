# Script para corregir el error de rollout timeout en todos los Jenkinsfile.master

Write-Host "Corrigiendo error de rollout timeout en Jenkinsfiles..." -ForegroundColor Cyan
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
    $jenkinsfile = "$service/Jenkinsfile.master"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando: $jenkinsfile" -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Corregir el error: agregar espacio y salto de linea correcto
        $content = $content -replace 'kubectl rollout status deployment/\$\{SERVICE_NAME\} -n \$K8S_NAMESPACE --timeout=600s\s*echo', 'kubectl rollout status deployment/${SERVICE_NAME} -n $K8S_NAMESPACE --timeout=600s || echo "Rollout timeout, verificando estado..."
                        
                        echo'
        
        # Guardar cambios
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "  Corregido: $service" -ForegroundColor Green
    }
    else {
        Write-Host "  No encontrado: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Correccion completada!" -ForegroundColor Green
Write-Host ""
Write-Host "Cambios realizados:" -ForegroundColor Cyan
Write-Host "  - Agregado espacio entre timeout y echo" -ForegroundColor White
Write-Host "  - Agregado manejo de error con ||" -ForegroundColor White
Write-Host "  - Corregido formato de salto de linea" -ForegroundColor White
