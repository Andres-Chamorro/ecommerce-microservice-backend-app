# Script para corregir el docker cp path en todos los Jenkinsfiles

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service"
)

Write-Host "Corrigiendo docker cp path en Jenkinsfiles..." -ForegroundColor Cyan

foreach ($service in $services) {
    foreach ($file in @("Jenkinsfile", "Jenkinsfile.dev")) {
        $jenkinsfile = "$service/$file"
        
        if (Test-Path $jenkinsfile) {
            Write-Host "`nActualizando $jenkinsfile..." -ForegroundColor Yellow
            
            # Leer contenido sin BOM
            $bytes = [System.IO.File]::ReadAllBytes($jenkinsfile)
            $content = [System.Text.Encoding]::UTF8.GetString($bytes)
            
            # Reemplazar el bloque de docker cp
            $oldPattern = 'docker cp /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar minikube:/tmp/\s+docker exec minikube ctr'
            $newBlock = @"
docker cp /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar minikube:/tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Verificar que el archivo existe en Minikube
                        docker exec minikube ls -lh /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Importar imagen
                        docker exec minikube ctr
"@
            
            if ($content -match $oldPattern) {
                $content = $content -replace $oldPattern, $newBlock
                
                # Guardar sin BOM
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($jenkinsfile, $content, $utf8NoBom)
                
                Write-Host "  Actualizado!" -ForegroundColor Green
            } else {
                Write-Host "  Patron no encontrado, copiando desde shipping-service..." -ForegroundColor Yellow
                
                # Copiar desde shipping-service que ya está correcto
                $templateBytes = [System.IO.File]::ReadAllBytes("shipping-service/$file")
                $templateContent = [System.Text.Encoding]::UTF8.GetString($templateBytes)
                
                # Reemplazar el nombre del servicio
                $serviceContent = $templateContent -replace 'shipping-service', $service
                
                # Guardar sin BOM
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($jenkinsfile, $serviceContent, $utf8NoBom)
                
                Write-Host "  Copiado desde template!" -ForegroundColor Green
            }
        }
    }
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
