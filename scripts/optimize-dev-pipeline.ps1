# Script para optimizar pipeline de DEV usando registry

$services = @(
    "user-service",
    "product-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Optimizando pipelines de DEV para usar registry..." -ForegroundColor Cyan

foreach ($service in $services) {
    foreach ($file in @("Jenkinsfile", "Jenkinsfile.dev")) {
        $jenkinsfile = "$service/$file"
        
        if (Test-Path $jenkinsfile) {
            Write-Host "`nActualizando $jenkinsfile..." -ForegroundColor Yellow
            
            # Copiar desde order-service que ya está optimizado
            $templateBytes = [System.IO.File]::ReadAllBytes("order-service/$file")
            $templateContent = [System.Text.Encoding]::UTF8.GetString($templateBytes)
            
            # Reemplazar el nombre del servicio
            $serviceContent = $templateContent -replace 'order-service', $service
            
            # Guardar sin BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($jenkinsfile, $serviceContent, $utf8NoBom)
            
            Write-Host "  Actualizado!" -ForegroundColor Green
        }
    }
}

Write-Host "`nOptimizacion completada!" -ForegroundColor Green
Write-Host "Cambios:" -ForegroundColor White
Write-Host "  - Eliminado docker save/load del stage Build (era muy lento)" -ForegroundColor White
Write-Host "  - Deploy usa imagen del registry con imagePullPolicy: Always" -ForegroundColor White
Write-Host "  - Pipeline deberia ser mucho mas rapido (~4-8 min vs 22+ min)" -ForegroundColor White
