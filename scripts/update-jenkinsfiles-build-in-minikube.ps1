# Script para actualizar Jenkinsfiles para construir directamente en minikube

Write-Host "Actualizando Jenkinsfiles para construir en minikube..." -ForegroundColor Green

$services = @('user-service', 'shipping-service', 'product-service', 'payment-service', 'order-service', 'favourite-service')

foreach ($service in $services) {
    $file = "$service/Jenkinsfile"
    
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Buscar y reemplazar la sección de Build Docker Image
        $oldBuildSection = @'
                    sh """
                        # Construir imagen
                        cd product-service
                        docker build -t \${IMAGE_NAME}:dev-\${BUILD_TAG} .
                        docker tag \${IMAGE_NAME}:dev-\${BUILD_TAG} \${IMAGE_NAME}:dev-latest
                        cd ..
                        
                        # Cargar en Minikube usando docker load (más rápido)
                        docker save \${IMAGE_NAME}:dev-\${BUILD_TAG} | docker exec -i minikube docker load
                        
                        echo "Imagen construida y cargada en Minikube: \${IMAGE_NAME}:dev-\${BUILD_TAG}"
                    """
'@

        $newBuildSection = @"
                    sh """
                        # Construir imagen DIRECTAMENTE en minikube (sin transferencia)
                        cd $service
                        
                        # Copiar contexto de build a minikube
                        docker exec minikube mkdir -p /tmp/build-$service
                        docker cp . minikube:/tmp/build-$service/
                        
                        # Construir en minikube
                        docker exec minikube docker build -t \${IMAGE_NAME}:dev-\${BUILD_TAG} /tmp/build-$service
                        docker exec minikube docker tag \${IMAGE_NAME}:dev-\${BUILD_TAG} \${IMAGE_NAME}:dev-latest
                        
                        # Limpiar
                        docker exec minikube rm -rf /tmp/build-$service
                        
                        echo "Imagen construida directamente en Minikube: \${IMAGE_NAME}:dev-\${BUILD_TAG}"
                    """
"@
        
        # Reemplazar para cada servicio
        $servicePattern = $service -replace '-service', ''
        $content = $content -replace "cd $service\s+docker build", "cd $service`n                        `n                        # Copiar contexto de build a minikube`n                        docker exec minikube mkdir -p /tmp/build-$service`n                        docker cp . minikube:/tmp/build-$service/`n                        `n                        # Construir en minikube`n                        docker exec minikube docker build"
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText("$PWD\$file", $content, $utf8NoBom)
        
        Write-Host "✓ Actualizado $file" -ForegroundColor Green
    }
}

Write-Host "`n✓ Actualización completada!" -ForegroundColor Green
Write-Host "Ahora las imágenes se construyen directamente en minikube (sin transferencia)" -ForegroundColor Cyan
