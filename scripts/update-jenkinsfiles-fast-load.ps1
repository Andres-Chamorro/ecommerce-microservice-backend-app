# Script para actualizar Jenkinsfiles con carga rápida de imágenes

Write-Host "Actualizando Jenkinsfiles para carga rápida en Minikube..." -ForegroundColor Green

$services = @('user-service', 'shipping-service', 'product-service', 'payment-service', 'order-service', 'favourite-service')

foreach ($service in $services) {
    $file = "$service/Jenkinsfile"
    
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Buscar la sección de Build Docker Image y reemplazar la carga
        $oldPattern = 'docker save \$\{IMAGE_NAME\}:dev-\$\{BUILD_TAG\} \| docker exec -i minikube ctr -n k8s\.io images import -'
        $newPattern = @'
# Guardar imagen en archivo tar temporal
                        docker save ${IMAGE_NAME}:dev-${BUILD_TAG} -o /tmp/${IMAGE_NAME}-${BUILD_TAG}.tar
                        
                        # Copiar tar al host y cargar en minikube (más rápido)
                        docker cp /tmp/${IMAGE_NAME}-${BUILD_TAG}.tar jenkins_host:/tmp/
                        docker exec jenkins_host minikube image load ${IMAGE_NAME}:dev-${BUILD_TAG}
                        
                        # Limpiar archivo temporal
                        rm -f /tmp/${IMAGE_NAME}-${BUILD_TAG}.tar
'@
        
        if ($content -match [regex]::Escape($oldPattern)) {
            $content = $content -replace [regex]::Escape($oldPattern), $newPattern
            
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText("$PWD\$file", $content, $utf8NoBom)
            
            Write-Host "✓ Actualizado $file" -ForegroundColor Green
        } else {
            Write-Host "⚠ No se encontró el patrón en $file" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✓ Actualización completada!" -ForegroundColor Green
Write-Host "Ahora los pipelines usarán minikube image load (mucho más rápido)" -ForegroundColor Cyan
