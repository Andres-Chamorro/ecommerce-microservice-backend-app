# Script para actualizar Jenkinsfiles usando minikube image load
# Ahora que minikube esta instalado en Jenkins, podemos usar este comando

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Actualizando Jenkinsfiles.dev para usar minikube image load..." -ForegroundColor Cyan

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
                        
                        # Cargar imagen en Minikube usando minikube image load
                        minikube image load `${IMAGE_NAME}:dev-`${BUILD_TAG} --profile=minikube
                        
                        # Verificar que la imagen existe en Minikube
                        minikube image ls --profile=minikube | grep `${IMAGE_NAME} || echo "WARNING: Imagen no encontrada en Minikube"
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
Write-Host "Estrategia simplificada:" -ForegroundColor White
Write-Host "  1. Construir imagen con docker build" -ForegroundColor White
Write-Host "  2. Cargar imagen en Minikube con 'minikube image load'" -ForegroundColor White
Write-Host "  3. Verificar con 'minikube image ls'" -ForegroundColor White
