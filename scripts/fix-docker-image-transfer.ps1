Write-Host "Actualizando metodo de transferencia de imagenes Docker..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar y reemplazar el bloque de Build Docker Image
        $oldBlock = @'
                        # Guardar imagen a archivo tar
                        docker save \$\{IMAGE_NAME\}:dev-\$\{BUILD_TAG\} -o /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar
                        
                        # Cargar imagen en Minikube
                        docker cp /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar minikube:/tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar
                        
                        # Verificar que el archivo existe en Minikube
                        docker exec minikube ls -lh /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar
                        
                        # Importar imagen
                        docker exec minikube ctr -n k8s\.io images import /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar
                        
                        # Limpiar archivos temporales
                        rm -f /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar
                        docker exec minikube rm -f /tmp/\$\{IMAGE_NAME\}-dev-\$\{BUILD_TAG\}\.tar
'@

        $newBlock = @'
                        # Transferir imagen directamente a Minikube usando pipe
                        docker save ${IMAGE_NAME}:dev-${BUILD_TAG} | docker exec -i minikube ctr -n k8s.io images import -
'@

        $content = $content -replace [regex]::Escape($oldBlock), $newBlock
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles actualizados con transferencia directa via pipe" -ForegroundColor Green
Write-Host "Ahora las imagenes se transfieren sin archivos temporales" -ForegroundColor Cyan
