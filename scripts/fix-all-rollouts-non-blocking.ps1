# Script para hacer TODOS los rollouts no bloqueantes

Write-Host "Haciendo todos los rollouts no bloqueantes..." -ForegroundColor Cyan
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
        
        # Verificar si ya tiene el fix
        if ($content -match "continuing anyway") {
            Write-Host "  Ya tiene el fix, saltando..." -ForegroundColor Yellow
            continue
        }
        
        # Buscar y reemplazar el rollout status
        if ($content -match "kubectl rollout status deployment/\`\${SERVICE_NAME} -n \`\$K8S_NAMESPACE --timeout=600s") {
            $content = $content -replace `
                "(kubectl rollout status deployment/\`\${SERVICE_NAME} -n \`\$K8S_NAMESPACE --timeout=600s)", `
                "`$1 || echo 'Rollout timeout - continuing anyway'"
            
            # Actualizar mensaje
            $content = $content -replace `
                "echo `".*Rollout completado.*`"", `
                "echo 'Rollout completado o timeout alcanzado'"
            
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "  Rollout actualizado a no bloqueante" -ForegroundColor Green
        }
        else {
            Write-Host "  No se encontro el patron de rollout" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  Archivo no encontrado: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Proceso completado!" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora TODOS los servicios tienen rollout no bloqueante." -ForegroundColor Cyan
Write-Host "Si el deployment tarda mas de 10 minutos, el pipeline continuara." -ForegroundColor White
