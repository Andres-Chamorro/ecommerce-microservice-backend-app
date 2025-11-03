# Script para actualizar todos los servicios con docker save | docker load

$services = @(
    "user-service",
    "product-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Actualizando todos los servicios con docker save | docker load..." -ForegroundColor Cyan

foreach ($service in $services) {
    foreach ($file in @("Jenkinsfile", "Jenkinsfile.dev")) {
        $jenkinsfile = "$service/$file"
        
        if (Test-Path $jenkinsfile) {
            Write-Host "`nActualizando $jenkinsfile..." -ForegroundColor Yellow
            
            # Copiar desde order-service que ya está correcto
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

Write-Host "`nActualizacion completada!" -ForegroundColor Green
Write-Host "Todos los servicios usan: docker save | docker exec -i minikube docker load" -ForegroundColor White
Write-Host "imagePullPolicy: IfNotPresent" -ForegroundColor White
