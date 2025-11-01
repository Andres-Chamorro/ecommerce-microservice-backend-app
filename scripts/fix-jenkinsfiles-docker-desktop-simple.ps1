# Script simple para actualizar Jenkinsfiles para Docker Desktop Kubernetes
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
        
        # Buscar y reemplazar el stage de Deploy to Minikube
        if ($content -match "stage\(.Deploy to Minikube.\)") {
            # Crear el nuevo contenido del stage
            $newStage = "        stage('Deploy to Docker Desktop K8s') {`n"
            $newStage += "            when {`n"
            $newStage += "                expression { params.SKIP_DEPLOY == false }`n"
            $newStage += "            }`n"
            $newStage += "            steps {`n"
            $newStage += "                script {`n"
            $newStage += "                    echo `"🚀 [DEV] Desplegando `${SERVICE_NAME} en Docker Desktop Kubernetes...`"`n"
            $newStage += "                    `n"
            $newStage += "                    bat `"`"`"`n"
            $newStage += "                        @echo off`n"
            $newStage += "                        echo Configurando contexto de Docker Desktop Kubernetes...`n"
            $newStage += "                        kubectl config use-context docker-desktop`n"
            $newStage += "                        `n"
            $newStage += "                        echo Creando namespace si no existe...`n"
            $newStage += "                        kubectl create namespace %K8S_NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -`n"
            $newStage += "                        `n"
            $newStage += "                        echo Desplegando %SERVICE_NAME%...`n"
            $newStage += "                        (`n"
            $newStage += "                        echo apiVersion: apps/v1`n"
            $newStage += "                        echo kind: Deployment`n"
            $newStage += "                        echo metadata:`n"
            $newStage += "                        echo   name: %SERVICE_NAME%`n"
            $newStage += "                        echo   namespace: %K8S_NAMESPACE%`n"
            $newStage += "                        echo spec:`n"
            $newStage += "                        echo   replicas: 1`n"
            $newStage += "                        echo   selector:`n"
            $newStage += "                        echo     matchLabels:`n"
            $newStage += "                        echo       app: %SERVICE_NAME%`n"
            $newStage += "                        echo   template:`n"
            $newStage += "                        echo     metadata:`n"
            $newStage += "                        echo       labels:`n"
            $newStage += "                        echo         app: %SERVICE_NAME%`n"
            $newStage += "                        echo     spec:`n"
            $newStage += "                        echo       containers:`n"
            $newStage += "                        echo       - name: %SERVICE_NAME%`n"
            $newStage += "                        echo         image: %IMAGE_NAME%:dev-%BUILD_TAG%`n"
            $newStage += "                        echo         ports:`n"
            $newStage += "                        echo         - containerPort: %SERVICE_PORT%`n"
            $newStage += "                        echo         imagePullPolicy: Never`n"
            $newStage += "                        echo         env:`n"
            $newStage += "                        echo         - name: SPRING_PROFILES_ACTIVE`n"
            $newStage += "                        echo           value: `"dev`"`n"
            $newStage += "                        echo ---`n"
            $newStage += "                        echo apiVersion: v1`n"
            $newStage += "                        echo kind: Service`n"
            $newStage += "                        echo metadata:`n"
            $newStage += "                        echo   name: %SERVICE_NAME%`n"
            $newStage += "                        echo   namespace: %K8S_NAMESPACE%`n"
            $newStage += "                        echo spec:`n"
            $newStage += "                        echo   selector:`n"
            $newStage += "                        echo     app: %SERVICE_NAME%`n"
            $newStage += "                        echo   ports:`n"
            $newStage += "                        echo   - port: %SERVICE_PORT%`n"
            $newStage += "                        echo     targetPort: %SERVICE_PORT%`n"
            $newStage += "                        echo   type: ClusterIP`n"
            $newStage += "                        ^) | kubectl apply -f -`n"
            $newStage += "                        `n"
            $newStage += "                        echo Esperando a que el deployment este listo...`n"
            $newStage += "                        kubectl rollout status deployment/%SERVICE_NAME% -n %K8S_NAMESPACE% --timeout=180s`n"
            $newStage += "                    `"`"`"`n"
            $newStage += "                }`n"
            $newStage += "            }`n"
            $newStage += "        }"
            
            # Usar regex para reemplazar todo el stage
            $pattern = "(?s)stage\(.Deploy to Minikube.\).*?(?=\n\s{8}stage\(.|\n\s{4}\})"
            $content = $content -replace $pattern, $newStage
            
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
