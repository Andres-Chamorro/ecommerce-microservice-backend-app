# Script para arreglar el problema de ImagePullBackOff en Jenkinsfiles.dev
# Cambia la construccion de imagenes para usar minikube image build
# y cambia imagePullPolicy a Never

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Actualizando Jenkinsfiles.dev para usar minikube image build..." -ForegroundColor Cyan

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "`nActualizando $jenkinsfile..." -ForegroundColor Yellow
        
        # Leer contenido
        $content = Get-Content $jenkinsfile -Raw -Encoding UTF8
        
        # 1. Cambiar el stage de Build Docker Image
        $oldBuildStage = @"
                    sh """
                        # Usar el Docker daemon de Minikube
                        eval \`$(minikube docker-env) || true
                        
                        docker build -t `${IMAGE_NAME}:dev-`${BUILD_TAG} -f $service/Dockerfile .
                        docker tag `${IMAGE_NAME}:dev-`${BUILD_TAG} `${IMAGE_NAME}:dev-latest
                    """
"@
        
        $newBuildStage = @"
                    sh """
                        # Construir imagen directamente en Minikube
                        minikube image build -t `${IMAGE_NAME}:dev-`${BUILD_TAG} -f $service/Dockerfile .
                        minikube image build -t `${IMAGE_NAME}:dev-latest -f $service/Dockerfile .
                        
                        # Verificar que la imagen existe
                        minikube image ls | grep `${IMAGE_NAME} || echo "WARNING: Imagen no encontrada"
                    """
"@
        
        $content = $content -replace [regex]::Escape($oldBuildStage), $newBuildStage
        
        # 2. Cambiar imagePullPolicy de IfNotPresent a Never
        $content = $content -replace 'imagePullPolicy: IfNotPresent', 'imagePullPolicy: Never'
        
        # Guardar cambios
        $content | Out-File -FilePath $jenkinsfile -Encoding UTF8 -NoNewline
        
        Write-Host "  Actualizado!" -ForegroundColor Green
    } else {
        Write-Host "  No encontrado: $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
Write-Host "Cambios realizados:" -ForegroundColor White
Write-Host "  1. Usar 'minikube image build' en lugar de 'docker build'" -ForegroundColor White
Write-Host "  2. Cambiar imagePullPolicy a 'Never'" -ForegroundColor White
