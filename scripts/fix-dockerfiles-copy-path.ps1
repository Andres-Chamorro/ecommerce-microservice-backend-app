Write-Host "Corrigiendo rutas COPY en Dockerfiles..." -ForegroundColor Cyan

$services = @(
    @{name="user-service"; port="8300"},
    @{name="order-service"; port="8100"},
    @{name="product-service"; port="8200"},
    @{name="payment-service"; port="8400"},
    @{name="favourite-service"; port="8600"}
)

foreach ($service in $services) {
    $serviceName = $service.name
    $servicePort = $service.port
    $dockerfile = "$serviceName/Dockerfile"
    
    if (Test-Path $dockerfile) {
        Write-Host "Actualizando $dockerfile..." -ForegroundColor Yellow
        
        $content = Get-Content $dockerfile -Raw
        
        # Corregir la ruta del COPY para que incluya el nombre del servicio
        $content = $content -replace "COPY target/$serviceName", "COPY $serviceName/target/$serviceName"
        
        $content | Set-Content $dockerfile -NoNewline
        
        Write-Host "OK $dockerfile actualizado" -ForegroundColor Green
    } else {
        Write-Host "ADVERTENCIA: $dockerfile no encontrado" -ForegroundColor Yellow
    }
}

Write-Host "`nTodos los Dockerfiles actualizados" -ForegroundColor Green
