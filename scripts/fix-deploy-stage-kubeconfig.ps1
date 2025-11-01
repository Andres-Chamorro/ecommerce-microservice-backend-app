# Script para actualizar el stage de Deploy en todos los Jenkinsfiles
Write-Host "Actualizando stage de Deploy en todos los Jenkinsfiles..." -ForegroundColor Green

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

$deployStage = @'
        stage('Deploy to Minikube') {
            steps {
                script {
                    echo "Deploying to Minikube..."
                    
                    // Usar el kubeconfig que ya está configurado
                    sh '''
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        
                        # Verificar conexión
                        kubectl version --client
                        kubectl cluster-info
                        
                        # Aplicar deployment
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Verificar deployment
                        kubectl rollout status deployment/${SERVICE_NAME} -n default --timeout=2m
                        kubectl get pods -n default -l app=${SERVICE_NAME}
                    '''
                }
            }
        }
'@

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar y reemplazar el stage de Deploy
        $pattern = "(?s)stage\('Deploy to Minikube'\)\s*\{.*?^\s{8}\}"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $deployStage.Trim()
            $content | Set-Content $jenkinsfile -NoNewline
            Write-Host "✓ $jenkinsfile actualizado" -ForegroundColor Green
        } else {
            Write-Host "✗ No se encontró el stage de Deploy en $jenkinsfile" -ForegroundColor Red
        }
    }
}

Write-Host "`nActualización completada!" -ForegroundColor Green
