# Script para desplegar todos los servicios manualmente en Minikube

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Despliegue Manual de Todos los Servicios" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$namespace = "ecommerce-dev"

$services = @(
    @{Name="user-service"; Port="8700"},
    @{Name="product-service"; Port="8200"},
    @{Name="order-service"; Port="8300"},
    @{Name="payment-service"; Port="8400"},
    @{Name="favourite-service"; Port="8800"},
    @{Name="shipping-service"; Port="8600"}
)

# 1. Crear namespace
Write-Host "1. Verificando namespace..." -ForegroundColor Yellow
kubectl get namespace $namespace 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Creando namespace $namespace..." -ForegroundColor Cyan
    kubectl create namespace $namespace
} else {
    Write-Host "   ✓ Namespace $namespace ya existe" -ForegroundColor Green
}
Write-Host ""

# 2. Construir y cargar imágenes
Write-Host "2. Construyendo y cargando imágenes Docker..." -ForegroundColor Yellow
foreach ($service in $services) {
    $serviceName = $service.Name
    Write-Host "   Procesando $serviceName..." -ForegroundColor Cyan
    
    Write-Host "     - Construyendo imagen..." -ForegroundColor Gray
    docker build -t ${serviceName}:dev-manual -f $serviceName/Dockerfile . 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "     ✓ Imagen construida" -ForegroundColor Green
        
        Write-Host "     - Cargando en Minikube..." -ForegroundColor Gray
        docker save ${serviceName}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "     ✓ Imagen cargada en Minikube" -ForegroundColor Green
        } else {
            Write-Host "     ✗ Error al cargar imagen en Minikube" -ForegroundColor Red
        }
    } else {
        Write-Host "     ✗ Error al construir imagen" -ForegroundColor Red
    }
}
Write-Host ""

# 3. Desplegar servicios
Write-Host "3. Desplegando servicios en Kubernetes..." -ForegroundColor Yellow
foreach ($service in $services) {
    $serviceName = $service.Name
    $servicePort = $service.Port
    
    Write-Host "   Desplegando $serviceName..." -ForegroundColor Cyan
    
    # Crear archivo YAML temporal
    $tempFile = "temp-$serviceName.yaml"
    
    $yamlContent = "apiVersion: apps/v1`n"
    $yamlContent += "kind: Deployment`n"
    $yamlContent += "metadata:`n"
    $yamlContent += "  name: $serviceName`n"
    $yamlContent += "  namespace: $namespace`n"
    $yamlContent += "spec:`n"
    $yamlContent += "  replicas: 1`n"
    $yamlContent += "  selector:`n"
    $yamlContent += "    matchLabels:`n"
    $yamlContent += "      app: $serviceName`n"
    $yamlContent += "  template:`n"
    $yamlContent += "    metadata:`n"
    $yamlContent += "      labels:`n"
    $yamlContent += "        app: $serviceName`n"
    $yamlContent += "    spec:`n"
    $yamlContent += "      containers:`n"
    $yamlContent += "      - name: $serviceName`n"
    $yamlContent += "        image: ${serviceName}:dev-manual`n"
    $yamlContent += "        ports:`n"
    $yamlContent += "        - containerPort: $servicePort`n"
    $yamlContent += "        imagePullPolicy: Never`n"
    $yamlContent += "        env:`n"
    $yamlContent += "        - name: SPRING_PROFILES_ACTIVE`n"
    $yamlContent += "          value: dev`n"
    $yamlContent += "---`n"
    $yamlContent += "apiVersion: v1`n"
    $yamlContent += "kind: Service`n"
    $yamlContent += "metadata:`n"
    $yamlContent += "  name: $serviceName`n"
    $yamlContent += "  namespace: $namespace`n"
    $yamlContent += "spec:`n"
    $yamlContent += "  selector:`n"
    $yamlContent += "    app: $serviceName`n"
    $yamlContent += "  ports:`n"
    $yamlContent += "  - port: $servicePort`n"
    $yamlContent += "    targetPort: $servicePort`n"
    $yamlContent += "  type: ClusterIP`n"
    
    $yamlContent | Out-File -FilePath $tempFile -Encoding UTF8
    
    kubectl apply -f $tempFile 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "     ✓ Desplegado" -ForegroundColor Green
    } else {
        Write-Host "     ✗ Error al desplegar" -ForegroundColor Red
    }
    
    Remove-Item $tempFile -ErrorAction SilentlyContinue
}
Write-Host ""

# 4. Esperar a que los pods estén listos
Write-Host "4. Esperando a que los pods estén listos..." -ForegroundColor Yellow
Write-Host "   (Esto puede tomar 1-2 minutos)" -ForegroundColor Gray
Write-Host ""

Start-Sleep -Seconds 10

foreach ($service in $services) {
    $serviceName = $service.Name
    Write-Host "   Esperando $serviceName..." -ForegroundColor Cyan
    
    $maxAttempts = 24
    $attempt = 0
    $ready = $false
    
    while ($attempt -lt $maxAttempts -and -not $ready) {
        $attempt++
        
        $podStatus = kubectl get pods -n $namespace -l app=$serviceName -o jsonpath="{.items[0].status.phase}" 2>$null
        
        if ($podStatus -eq "Running") {
            Write-Host "     ✓ Pod corriendo" -ForegroundColor Green
            $ready = $true
        } else {
            Write-Host "     - Intento $attempt/$maxAttempts - Estado: $podStatus" -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    }
    
    if (-not $ready) {
        Write-Host "     ⚠ Timeout esperando el pod" -ForegroundColor Yellow
    }
}
Write-Host ""

# 5. Verificar estado final
Write-Host "5. Estado final de los servicios:" -ForegroundColor Yellow
Write-Host ""
kubectl get pods -n $namespace
Write-Host ""
kubectl get svc -n $namespace
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Despliegue completado" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ahora puedes ejecutar cualquier pipeline en Jenkins" -ForegroundColor Cyan
Write-Host "y las pruebas de integración deberían funcionar." -ForegroundColor Cyan
Write-Host ""
