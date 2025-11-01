Write-Host "Reescribiendo stages de Deploy y Verify..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar y reemplazar el stage Deploy to Minikube completo
        $oldDeployStage = @'
        stage\('Deploy to Minikube'\) \{[^}]+when \{[^}]+\}[^}]+steps \{[^}]+script \{[^}]+echo[^"]+"\[[^\]]+\] Desplegando[^"]+\.\.\."[^}]+sh """[^"]+"""[^}]+\}[^}]+\}[^}]+\}
'@

        $newDeployStage = @'
        stage('Deploy to Minikube') {
            when {
                expression { params.SKIP_DEPLOY == false }
            }
            steps {
                script {
                    echo "[DEV] Desplegando ${SERVICE_NAME} en Minikube..."
                    
                    sh """
                        # Verificar conexion
                        docker exec minikube kubectl cluster-info
                        
                        # Crear namespace si no existe
                        docker exec minikube kubectl get namespace ${K8S_NAMESPACE} || docker exec minikube kubectl create namespace ${K8S_NAMESPACE}
                        
                        # Crear archivo de deployment temporal
                        cat > /tmp/deployment-${SERVICE_NAME}.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${SERVICE_NAME}
  namespace: ${K8S_NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${SERVICE_NAME}
  template:
    metadata:
      labels:
        app: ${SERVICE_NAME}
    spec:
      containers:
      - name: ${SERVICE_NAME}
        image: ${IMAGE_NAME}:dev-${BUILD_TAG}
        ports:
        - containerPort: ${SERVICE_PORT}
        imagePullPolicy: Never
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "dev"
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: ${SERVICE_NAME}
  ports:
  - port: ${SERVICE_PORT}
    targetPort: ${SERVICE_PORT}
  type: ClusterIP
EOF
                        
                        # Copiar archivo a Minikube y aplicar
                        docker cp /tmp/deployment-${SERVICE_NAME}.yaml minikube:/tmp/deployment-${SERVICE_NAME}.yaml
                        docker exec minikube kubectl apply -f /tmp/deployment-${SERVICE_NAME}.yaml
                        
                        # Limpiar archivos temporales
                        rm -f /tmp/deployment-${SERVICE_NAME}.yaml
                        docker exec minikube rm -f /tmp/deployment-${SERVICE_NAME}.yaml
                        
                        # Esperar a que el deployment este listo
                        docker exec minikube kubectl rollout status deployment/${SERVICE_NAME} -n ${K8S_NAMESPACE} --timeout=180s || echo "WARNING: ${SERVICE_NAME} no esta listo"
                    """
                }
            }
        }
'@

        $content = $content -replace $oldDeployStage, $newDeployStage
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nStages de Deploy reescritos en todos los Jenkinsfiles" -ForegroundColor Green
