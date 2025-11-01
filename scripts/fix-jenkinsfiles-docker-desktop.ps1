# Script para actualizar Jenkinsfiles para usar Docker Desktop Kubernetes
# Este script reemplaza la configuración de Minikube por Docker Desktop Kubernetes

Write-Host "=== ACTUALIZANDO JENKINSFILES PARA DOCKER DESKTOP KUBERNETES ===" -ForegroundColor Cyan

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

$updated = 0

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "`nActualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar el stage completo de Deploy to Minikube
        $oldDeployStage = @"
        stage\('Deploy to Minikube'\) \{
            when \{
                expression \{ params\.SKIP_DEPLOY == false \}
            \}
            steps \{
                script \{
                    echo ".*"
                    
                    sh """
                        # Configurar KUBECONFIG explÃ­citamente
                        export KUBECONFIG=/var/jenkins_home/\.kube/config
                        
                        # Configurar servidor de Minikube
                        kubectl config set-cluster minikube --server=http://192\.168\.67\.2:2376 --insecure-skip-tls-verify=true
                        
                        # Cambiar contexto a Minikube
                        kubectl config set-credentials minikube-user --token=dummy
                        kubectl config set-context minikube --cluster=minikube --user=minikube-user
                        kubectl config use-context minikube
"@

        # Nuevo stage para Docker Desktop
        $newDeployStage = @'
        stage('Deploy to Docker Desktop K8s') {
            when {
                expression { params.SKIP_DEPLOY == false }
            }
            steps {
                script {
                    echo "🚀 [DEV] Desplegando ${SERVICE_NAME} en Docker Desktop Kubernetes..."
                    
                    // Usar PowerShell en el host Windows para ejecutar kubectl
                    bat """
                        @echo off
                        echo Configurando contexto de Docker Desktop Kubernetes...
                        kubectl config use-context docker-desktop
                        
                        echo Creando namespace si no existe...
                        kubectl create namespace %K8S_NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -
                        
                        echo Desplegando ${SERVICE_NAME}...
                        (
                        echo apiVersion: apps/v1
                        echo kind: Deployment
                        echo metadata:
                        echo   name: %SERVICE_NAME%
                        echo   namespace: %K8S_NAMESPACE%
                        echo spec:
                        echo   replicas: 1
                        echo   selector:
                        echo     matchLabels:
                        echo       app: %SERVICE_NAME%
                        echo   template:
                        echo     metadata:
                        echo       labels:
                        echo         app: %SERVICE_NAME%
                        echo     spec:
                        echo       containers:
                        echo       - name: %SERVICE_NAME%
                        echo         image: %IMAGE_NAME%:dev-%BUILD_TAG%
                        echo         ports:
                        echo         - containerPort: %SERVICE_PORT%
                        echo         imagePullPolicy: Never
                        echo         env:
                        echo         - name: SPRING_PROFILES_ACTIVE
                        echo           value: "dev"
                        echo ---
                        echo apiVersion: v1
                        echo kind: Service
                        echo metadata:
                        echo   name: %SERVICE_NAME%
                        echo   namespace: %K8S_NAMESPACE%
                        echo spec:
                        echo   selector:
                        echo     app: %SERVICE_NAME%
                        echo   ports:
                        echo   - port: %SERVICE_PORT%
                        echo     targetPort: %SERVICE_PORT%
                        echo   type: ClusterIP
                        ^) | kubectl apply -f -
                        
                        echo Esperando a que el deployment esté listo...
                        kubectl rollout status deployment/%SERVICE_NAME% -n %K8S_NAMESPACE% --timeout=180s
                    """
                }
            }
        }
'@
'@

        if ($content -match "stage\('Deploy to Minikube'\)") {
            # Encontrar y reemplazar todo el bloque del stage
            $pattern = "stage\('Deploy to Minikube'\).*?(?=\n\s{8}stage\('|$)"
            $content = $content -replace $pattern, $newDeployStage
            
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "✓ Actualizado exitosamente" -ForegroundColor Green
            $updated++
        } else {
            Write-Host "! No se encontró el stage 'Deploy to Minikube'" -ForegroundColor Red
        }
    } else {
        Write-Host "! Archivo no encontrado: $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos actualizados: $updated de $($services.Count)" -ForegroundColor $(if ($updated -eq $services.Count) { "Green" } else { "Yellow" })

Write-Host "`n=== CAMBIOS REALIZADOS ===" -ForegroundColor Cyan
Write-Host "1. Cambiado de 'Deploy to Minikube' a 'Deploy to Docker Desktop K8s'"
Write-Host "2. Usa comandos 'bat' (Windows) en lugar de 'sh' (Linux)"
Write-Host "3. Usa 'kubectl config use-context docker-desktop'"
Write-Host "4. Las imágenes Docker ya están disponibles (mismo daemon)"
Write-Host "5. Deployments usan imagePullPolicy: Never"

Write-Host "`n=== PRÓXIMOS PASOS ===" -ForegroundColor Cyan
Write-Host "1. Verifica que Docker Desktop Kubernetes esté activo:"
Write-Host "   kubectl config use-context docker-desktop"
Write-Host "   kubectl get nodes"
Write-Host ""
Write-Host "2. Ve a Jenkins: http://localhost:8079"
Write-Host "3. Ejecuta un pipeline (ej: order-service)"
Write-Host "4. Verifica el deployment:"
Write-Host "   kubectl get pods -n ecommerce-dev"
