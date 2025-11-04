# Script rápido para desplegar solo los servicios que faltan

$namespace = "ecommerce-dev"

$services = @(
    @{Name="user-service"; Port="8700"},
    @{Name="product-service"; Port="8200"},
    @{Name="order-service"; Port="8300"},
    @{Name="payment-service"; Port="8400"},
    @{Name="favourite-service"; Port="8800"},
    @{Name="shipping-service"; Port="8600"}
)

Write-Host "Verificando servicios desplegados..." -ForegroundColor Cyan
Write-Host ""

$missingServices = @()

foreach ($service in $services) {
    $serviceName = $service.Name
    $exists = kubectl get svc -n $namespace $serviceName 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ $serviceName - NO desplegado" -ForegroundColor Red
        $missingServices += $service
    } else {
        $podStatus = kubectl get pods -n $namespace -l app=$serviceName -o jsonpath='{.items[0].status.phase}' 2>$null
        if ($podStatus -eq "Running") {
            Write-Host "✓ $serviceName - Corriendo" -ForegroundColor Green
        } else {
            Write-Host "⚠ $serviceName - Desplegado pero no corriendo (Estado: $podStatus)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

if ($missingServices.Count -eq 0) {
    Write-Host "✓ Todos los servicios están desplegados" -ForegroundColor Green
    Write-Host ""
    Write-Host "Puedes ejecutar los pipelines con pruebas de integración" -ForegroundColor Cyan
    exit 0
}

Write-Host "Faltan $($missingServices.Count) servicios por desplegar" -ForegroundColor Yellow
Write-Host ""
Write-Host "¿Desplegar los servicios faltantes? (S/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -ne "S" -and $response -ne "s") {
    Write-Host "Operación cancelada" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Desplegando servicios faltantes..." -ForegroundColor Cyan
Write-Host ""

# Crear namespace si no existe
kubectl get namespace $namespace 2>$null
if ($LASTEXITCODE -ne 0) {
    kubectl create namespace $namespace
}

foreach ($service in $missingServices) {
    $serviceName = $service.Name
    $servicePort = $service.Port
    
    Write-Host "Desplegando $serviceName..." -ForegroundColor Cyan
    
    # Construir imagen
    Write-Host "  - Construyendo imagen..." -ForegroundColor Gray
    docker build -t ${serviceName}:dev-manual -f $serviceName/Dockerfile . 2>&1 | Out-Null
    
    # Cargar en Minikube
    Write-Host "  - Cargando en Minikube..." -ForegroundColor Gray
    docker save ${serviceName}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - 2>&1 | Out-Null
    
    # Desplegar
    Write-Host "  - Desplegando en Kubernetes..." -ForegroundColor Gray
    
    $tempFile = "temp-deploy-$serviceName.yaml"
    
    @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $serviceName
  namespace: $namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $serviceName
  template:
    metadata:
      labels:
        app: $serviceName
    spec:
      containers:
      - name: $serviceName
        image: ${serviceName}:dev-manual
        ports:
        - containerPort: $servicePort
        imagePullPolicy: Never
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "dev"
---
apiVersion: v1
kind: Service
metadata:
  name: $serviceName
  namespace: $namespace
spec:
  selector:
    app: $serviceName
  ports:
  - port: $servicePort
    targetPort: $servicePort
  type: ClusterIP
"@ | Out-File -FilePath $tempFile -Encoding UTF8
    
    kubectl apply -f $tempFile 2>&1 | Out-Null
    Remove-Item $tempFile
    Write-Host "  ✓ Desplegado" -ForegroundColor Green
}

Write-Host ""
Write-Host "Esperando a que los pods estén listos (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Estado actual:" -ForegroundColor Cyan
kubectl get pods -n $namespace

Write-Host ""
Write-Host "✓ Completado" -ForegroundColor Green
