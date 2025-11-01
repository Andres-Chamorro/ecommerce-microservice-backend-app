# Script para actualizar Jenkinsfiles para usar kubectl desde Windows host

Write-Host "=== ACTUALIZANDO JENKINSFILES PARA WINDOWS + DOCKER DESKTOP K8S ===" -ForegroundColor Cyan
Write-Host ""

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

$updatedCount = 0

foreach ($service in $services) {
    $jenkinsfilePath = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfilePath) {
        Write-Host "Actualizando $jenkinsfilePath..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfilePath -Raw -Encoding UTF8
        
        # Nuevo stage de Deploy que usa PowerShell desde Windows
        $newDeployStage = @'
        stage('Deploy to Kubernetes') {
            when {
                expression { params.SKIP_DEPLOY == false }
            }
            steps {
                script {
                    echo "Desplegando ${SERVICE_NAME} en Docker Desktop Kubernetes..."
                    
                    // Usar PowerShell para ejecutar kubectl en el host Windows
                    powershell """
                        # Configurar contexto de Docker Desktop
                        kubectl config use-context docker-desktop
                        
                        # Crear namespace si no existe
                        kubectl create namespace ${env.K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                        
                        # Aplicar manifiestos de Kubernetes
                        Write-Host 'Aplicando manifiestos de Kubernetes...'
                        kubectl apply -f ${env.SERVICE_NAME}/k8s/
                        
                        # Esperar a que el deployment este listo
                        Write-Host 'Esperando a que el deployment este listo...'
                        kubectl rollout status deployment/${env.SERVICE_NAME} -n ${env.K8S_NAMESPACE} --timeout=180s
                        
                        # Verificar pods
                        Write-Host 'Estado de los pods:'
                        kubectl get pods -n ${env.K8S_NAMESPACE} -l app=${env.SERVICE_NAME}
                        
                        # Verificar servicios
                        Write-Host 'Estado de los servicios:'
                        kubectl get svc -n ${env.K8S_NAMESPACE} ${env.SERVICE_NAME}
                        
                        Write-Host 'Deploy completado exitosamente'
                    """
                }
            }
        }
'@
        
        # Reemplazar el stage de Deploy existente
        $pattern = "stage\('Deploy to [^']+'\)\s*\{[\s\S]*?^\s{8}\}"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $newDeployStage
            
            # Guardar archivo
            $content | Out-File -FilePath $jenkinsfilePath -Encoding UTF8 -NoNewline
            
            Write-Host "   OK Actualizado $jenkinsfilePath" -ForegroundColor Green
            $updatedCount++
        } else {
            Write-Host "   ! No se encontro el stage de Deploy en $jenkinsfilePath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ! No encontrado: $jenkinsfilePath" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos actualizados: $updatedCount de $($services.Count)" -ForegroundColor Green
Write-Host ""
Write-Host "=== CAMBIOS REALIZADOS ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Los Jenkinsfiles ahora usan PowerShell para ejecutar kubectl" -ForegroundColor White
Write-Host "2. kubectl se ejecuta en el host Windows (no en el contenedor Jenkins)" -ForegroundColor White
Write-Host "3. Se conecta a Docker Desktop Kubernetes automaticamente" -ForegroundColor White
Write-Host "4. No necesita configuracion adicional en Jenkins" -ForegroundColor White
Write-Host ""
Write-Host "=== COMO FUNCIONA ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Jenkins construye la imagen Docker" -ForegroundColor White
Write-Host "2. La imagen queda en Docker local" -ForegroundColor White
Write-Host "3. Jenkins ejecuta PowerShell en Windows" -ForegroundColor White
Write-Host "4. PowerShell ejecuta kubectl (que ya funciona en tu maquina)" -ForegroundColor White
Write-Host "5. kubectl despliega en Docker Desktop Kubernetes" -ForegroundColor White
Write-Host "6. Kubernetes usa la imagen local (imagePullPolicy: Never)" -ForegroundColor White
Write-Host ""
Write-Host "=== IMPORTANTE ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Asegurate de que tus deployments de Kubernetes usen:" -ForegroundColor White
Write-Host "  imagePullPolicy: Never" -ForegroundColor Cyan
Write-Host ""
Write-Host "Esto le dice a Kubernetes que use la imagen local de Docker" -ForegroundColor White
Write-Host ""
Write-Host "=== PROXIMO PASO ===" -ForegroundColor Green
Write-Host ""
Write-Host "1. Ve a Jenkins: http://localhost:8079" -ForegroundColor White
Write-Host "2. Ejecuta el pipeline de order-service" -ForegroundColor White
Write-Host "3. Verifica el deployment:" -ForegroundColor White
Write-Host "   kubectl get pods -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
