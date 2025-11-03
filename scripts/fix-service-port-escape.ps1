# Script para escapar correctamente SERVICE_PORT en Jenkinsfiles

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

$jenkinsfiles = @(
    "Jenkinsfile",
    "Jenkinsfile.master"
)

Write-Host "Escapando SERVICE_PORT en Jenkinsfiles..." -ForegroundColor Yellow

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..." -ForegroundColor Cyan
            
            # Leer contenido
            $lines = Get-Content $filePath
            $modified = $false
            
            for ($i = 0; $i -lt $lines.Count; $i++) {
                # Buscar la línea problemática
                if ($lines[$i] -match 'SERVICE_URL="\\$EXTERNAL_IP:\$\{SERVICE_PORT\}"') {
                    # Reemplazar con escape correcto
                    $lines[$i] = $lines[$i] -replace '\$\{SERVICE_PORT\}', '\${SERVICE_PORT}'
                    $modified = $true
                    Write-Host "  Linea $($i+1) corregida" -ForegroundColor Green
                }
            }
            
            if ($modified) {
                # Guardar archivo
                $lines | Set-Content $filePath
                Write-Host "  Archivo actualizado" -ForegroundColor Green
            } else {
                Write-Host "  No se encontraron cambios necesarios" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
Write-Host "Proceso completado" -ForegroundColor Green
