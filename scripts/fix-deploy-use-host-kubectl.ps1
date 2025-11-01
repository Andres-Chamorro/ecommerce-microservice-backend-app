# Script para actualizar el stage de Deploy para usar kubectl desde el host
Write-Host "Actualizando stage de Deploy en todos los Jenkinsfiles..." -ForegroundColor Green

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar el stage de Deploy y reemplazarlo
        $oldPattern = "(?s)stage\('Deploy to Minikube'\).*?steps\s*\{.*?script\s*\{.*?\}\s*\}\s*\}"
        
        $newDeployStage = @'
        stage('Deploy to Minikube') {
            when {
                expression { params.SKIP_DEPLOY == false }
            }
            steps {
                script {
                    echo "Desplegando en Minikube..."
                    
                    // Ejecutar kubectl desde el host (fuera del contenedor Jenkins)
                    sh '''
                        # Actualizar imagen en deployment
                        sed -i "s|image:.*|image: ${IMAGE_NAME}:dev-${BUILD_TAG}|g" product-service/k8s/deployment.yaml
                        
                        # Aplicar deployment usando kubectl del host
                        docker exec minikube kubectl apply -f /hosthome/product-service/k8s/deployment.yaml
                        docker exec minikube kubectl apply -f /hosthome/product-service/k8s/service.yaml
                        
                        # Verificar deployment
                        docker exec minikube kubectl rollout status deployment/${SERVICE_NAME} -n default --timeout=2m
                        docker exec minikube kubectl get pods -n default -l app=${SERVICE_NAME}
                    '''
                }
            }
        }
'@
        
        if ($content -match $oldPattern) {
            $content = $content -replace $oldPattern, $newDeployStage.Trim()
            $content | Set-Content $jenkinsfile -NoNewline
            Write-Host "Actualizado $jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "No se encontro el stage de Deploy en $jenkinsfile" -ForegroundColor Red
        }
    }
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
Write-Host "Ahora kubectl se ejecutara desde el host usando 'docker exec minikube kubectl'" -ForegroundColor Cyan
