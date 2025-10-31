# Script para agregar push a registry en Jenkinsfiles de DEV

$services = @(
    "user-service",
    "product-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Agregando push a Artifact Registry en Jenkinsfiles de DEV..." -ForegroundColor Cyan

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
Write-Host "Cambios:" -ForegroundColor White
Write-Host "  - Agregado DOCKER_REGISTRY y REGISTRY_IMAGE en environment" -ForegroundColor White
Write-Host "  - Agregado stage 'Push to Registry' despues de Build" -ForegroundColor White
Write-Host "  - Las imagenes se pushean a Artifact Registry con tag dev-BUILD_NUMBER" -ForegroundColor White
