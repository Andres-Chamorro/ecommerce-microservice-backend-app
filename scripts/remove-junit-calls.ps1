# Script para eliminar completamente las llamadas a junit

Write-Host "Eliminando llamadas a junit de los Jenkinsfiles..." -ForegroundColor Cyan

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
        
        # Eliminar el bloque post con junit completamente
        $content = $content -replace "            post \{[^}]*junit[^}]*\}[^}]*\}", ""
        
        # Limpiar lineas vacias multiples
        $content = $content -replace "(\r?\n){3,}", "`n`n"
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "  Actualizado $jenkinsfile" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Proceso completado" -ForegroundColor Green
Write-Host "Las llamadas a junit han sido eliminadas" -ForegroundColor Cyan
Write-Host "Los tests seguiran ejecutandose, solo no habra reportes visuales en Jenkins" -ForegroundColor Yellow
