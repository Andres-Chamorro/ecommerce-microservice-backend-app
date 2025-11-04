# Script simple para desplegar todos los servicios

$namespace = "ecommerce-dev"
$services = @("user-service", "product-service", "order-service", "payment-service", "favourite-service", "shipping-service")
$ports = @{
    "user-service" = "8700"
    "product-service" = "8200"
    "order-service" = "8300"
    "payment-service" = "8400"
    "favourite-service" = "8800"
    "shipping-service" = "8600"
}

Write-Host "Desplegando servicios en Minikube..." -ForegroundColor Cyan
Write-Host ""

# Crear namespace
kubectl create namespace $namespace 2>$null

# Procesar cada servicio
foreach ($svc in $services) {
    Write-Host "[$svc]" -ForegroundColor Yellow
    
    # Construir imagen
    Write-Host "  Construyendo..." -ForegroundColor Gray
    docker build -t ${svc}:dev-manual -f $svc/Dockerfile . 2>&1 | Out-Null
    
    # Cargar en Minikube
    Write-Host "  Cargando en Minikube..." -ForegroundColor Gray
    docker save ${svc}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - 2>&1 | Out-Null
    
    # Crear YAML
    $port = $ports[$svc]
    $yaml = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $svc
  namespace: $namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $svc
  template:
    metadata:
      labels:
        app: $svc
    spec:
      containers:
      - name: $svc
        image: ${svc}:dev-manual
        ports:
        - containerPort: $port
        imagePullPolicy: Never
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: dev
---
apiVersion: v1
kind: Service
metadata:
  name: $svc
  namespace: $namespace
spec:
  selector:
    app: $svc
  ports:
  - port: $port
    targetPort: $port
  type: ClusterIP
"@
    
    $yaml | kubectl apply -f - 2>&1 | Out-Null
    Write-Host "  ✓ Desplegado" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Esperando 30 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Estado de los pods:" -ForegroundColor Cyan
kubectl get pods -n $namespace

Write-Host ""
Write-Host "✓ Completado" -ForegroundColor Green
