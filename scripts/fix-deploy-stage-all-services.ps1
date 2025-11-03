# Script para arreglar el stage de Deploy usando kubectl desde minikube

$services = @(
    @{name='user-service'; port='8700'},
    @{name='shipping-service'; port='8600'},
    @{name='product-service'; port='8300'},
    @{name='payment-service'; port='8400'},
    @{name='order-service'; port='8300'},
    @{name='favourite-service'; port='8200'}
)

foreach ($svc in $services) {
    $service = $svc.name
    $file = "$service/Jenkinsfile"
    
    Write-Host "Procesando $file..." -ForegroundColor Cyan
    
    $content = Get-Content $file -Raw
    
    # Reemplazar todo el bloque de deploy con uno que use docker exec minikube kubectl
    $pattern = '(?s)(stage\(''Deploy to Minikube''\).*?sh """).*?(kubectl apply -f -\s+EOF)'
    
    $newDeployBlock = @'
                    sh """
                        # Usar kubectl desde minikube directamente (sin problemas de red)
                        docker exec minikube kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | docker exec -i minikube kubectl apply -f -
                        
                        # Crear deployment
                        cat <<EOF | docker exec -i minikube kubectl apply -f -
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
                        
                        # Esperar deployment
                        docker exec minikube kubectl rollout status deployment/${SERVICE_NAME} -n ${K8S_NAMESPACE} --timeout=180s || echo "Deployment en progreso..."
'@
    
    if ($content -match $pattern) {
        $content = $content -replace $pattern, "`$1`n$newDeployBlock`n                        `$2"
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText("$PWD\$file", $content, $utf8NoBom)
        
        Write-Host "✓ Actualizado $file" -ForegroundColor Green
    } else {
        Write-Host "⚠ No se encontró el patrón en $file" -ForegroundColor Yellow
    }
}

Write-Host "`n✓ Deploy stages actualizados para usar kubectl desde minikube" -ForegroundColor Cyan
