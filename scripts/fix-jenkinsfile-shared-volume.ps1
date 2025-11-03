# Script para actualizar Jenkinsfiles usando volumen compartido
# Esta estrategia usa un volumen compartido entre Jenkins y el host

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Actualizando Jenkinsfiles.dev para usar volumen compartido..." -ForegroundColor Cyan

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "`nActualizando $jenkinsfile..." -ForegroundColor Yellow
        
        # Leer contenido
        $content = Get-Content $jenkinsfile -Raw -Encoding UTF8
        
        # Cambiar el stage de Build Docker Image
        $oldBuildStage = @"
                    sh """
                        # Construir imagen con Docker
                        docker build -t `${IMAGE_NAME}:dev-`${BUILD_TAG} -f $service/Dockerfile .
                        docker tag `${IMAGE_NAME}:dev-`${BUILD_TAG} `${IMAGE_NAME}:dev-latest
                        
                        # Guardar imagen a archivo tar
                        docker save `${IMAGE_NAME}:dev-`${BUILD_TAG} -o /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Cargar imagen en Minikube
                        docker cp /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar minikube:/tmp/
                        docker exec minikube ctr -n k8s.io images import /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Limpiar archivos temporales
                        rm -f /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        docker exec minikube rm -f /tmp/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Verificar que la imagen existe en Minikube
                        docker exec minikube crictl images | grep `${IMAGE_NAME} || echo "WARNING: Imagen no encontrada en Minikube"
                    """
"@
        
        $newBuildStage = @"
                    sh """
                        # Construir imagen con Docker
                        docker build -t `${IMAGE_NAME}:dev-`${BUILD_TAG} -f $service/Dockerfile .
                        docker tag `${IMAGE_NAME}:dev-`${BUILD_TAG} `${IMAGE_NAME}:dev-latest
                        
                        # Guardar imagen a archivo tar en volumen compartido
                        docker save `${IMAGE_NAME}:dev-`${BUILD_TAG} -o /var/jenkins_home/workspace/images/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Cargar imagen en Minikube usando el archivo del host
                        # El volumen jenkins_home esta montado en el host, podemos acceder desde ahi
                        docker exec minikube sh -c "docker load -i /host-workspace/images/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar"
                        
                        # Limpiar archivo temporal
                        rm -f /var/jenkins_home/workspace/images/`${IMAGE_NAME}-dev-`${BUILD_TAG}.tar
                        
                        # Verificar que la imagen existe en Minikube
                        docker exec minikube docker images | grep `${IMAGE_NAME} || echo "WARNING: Imagen no encontrada en Minikube"
                    """
"@
        
        $content = $content -replace [regex]::Escape($oldBuildStage), $newBuildStage
        
        # Guardar cambios
        $content | Out-File -FilePath $jenkinsfile -Encoding UTF8 -NoNewline
        
        Write-Host "  Actualizado!" -ForegroundColor Green
    } else {
        Write-Host "  No encontrado: $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
Write-Host "`nNOTA: Esta solucion requiere montar un volumen compartido." -ForegroundColor Yellow
Write-Host "Necesitamos configurar el volumen antes de ejecutar los pipelines." -ForegroundColor Yellow
