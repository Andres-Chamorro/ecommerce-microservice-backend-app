# Script final para desplegar todos los servicios

$namespace = "ecommerce-dev"
$services = @(
    @{name="user-service"; port=8700},
    @{name="product-service"; port=8200},
    @{name="order-service"; port=8300},
    @{name="payment-service"; port=8400},
    @{name="favourite-service"; port=8800},
    @{name="shipping-service"; port=8600}
)

Write-Host "Desplegando servicios en Minikube..." -ForegroundColor Cyan
Write-Host ""

# Crear namespace
kubectl create namespace $namespace 2>$null

# Procesar cada servicio
foreach ($svc in $services) {
    $svcName = $svc.name
    $svcPort = $svc.port
    
    Write-Host "[$svcName]" -ForegroundColor Yellow
    
    # Construir imagen
    Write-Host "  Construyendo..." -ForegroundColor Gray
    docker build -t ${svcName}:dev-manual -f $svcName/Dockerfile . 2>&1 | Out-Null
    
    # Cargar en Minikube
    Write-Host "  Cargando en Minikube..." -ForegroundColor Gray
    docker save ${svcName}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - 2>&1 | Out-Null
    
    # Crear archivo YAML
    $tempFile = "temp-$svcName.yaml"
    
    "apiVersion: apps/v1" | Out-File $tempFile
    "kind: Deployment" | Out-File $tempFile -Append
    "metadata:" | Out-File $tempFile -Append
    "  name: $svcName" | Out-File $tempFile -Append
    "  namespace: $namespace" | Out-File $tempFile -Append
    "spec:" | Out-File $tempFile -Append
    "  replicas: 1" | Out-File $tempFile -Append
    "  selector:" | Out-File $tempFile -Append
    "    matchLabels:" | Out-File $tempFile -Append
    "      app: $svcName" | Out-File $tempFile -Append
    "  template:" | Out-File $tempFile -Append
    "    metadata:" | Out-File $tempFile -Append
    "      labels:" | Out-File $tempFile -Append
    "        app: $svcName" | Out-File $tempFile -Append
    "    spec:" | Out-File $tempFile -Append
    "      containers:" | Out-File $tempFile -Append
    "      - name: $svcName" | Out-File $tempFile -Append
    "        image: ${svcName}:dev-manual" | Out-File $tempFile -Append
    "        ports:" | Out-File $tempFile -Append
    "        - containerPort: $svcPort" | Out-File $tempFile -Append
    "        imagePullPolicy: Never" | Out-File $tempFile -Append
    "        env:" | Out-File $tempFile -Append
    "        - name: SPRING_PROFILES_ACTIVE" | Out-File $tempFile -Append
    "          value: dev" | Out-File $tempFile -Append
    "---" | Out-File $tempFile -Append
    "apiVersion: v1" | Out-File $tempFile -Append
    "kind: Service" | Out-File $tempFile -Append
    "metadata:" | Out-File $tempFile -Append
    "  name: $svcName" | Out-File $tempFile -Append
    "  namespace: $namespace" | Out-File $tempFile -Append
    "spec:" | Out-File $tempFile -Append
    "  selector:" | Out-File $tempFile -Append
    "    app: $svcName" | Out-File $tempFile -Append
    "  ports:" | Out-File $tempFile -Append
    "  - port: $svcPort" | Out-File $tempFile -Append
    "    targetPort: $svcPort" | Out-File $tempFile -Append
    "  type: ClusterIP" | Out-File $tempFile -Append
    
    kubectl apply -f $tempFile 2>&1 | Out-Null
    Remove-Item $tempFile
    
    Write-Host "  ✓ Desplegado" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Esperando 30 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Estado de los pods:" -ForegroundColor Cyan
kubectl get pods -n $namespace

Write-Host ""
Write-Host "✓ Completado - Ahora puedes ejecutar pipelines con pruebas de integración" -ForegroundColor Green
