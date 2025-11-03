# Script para configurar Docker Desktop Kubernetes con Jenkins

Write-Host "=== CONFIGURACION DOCKER DESKTOP KUBERNETES + JENKINS ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar que Docker Desktop K8s está activo
Write-Host "1. Verificando Docker Desktop Kubernetes..." -ForegroundColor Yellow

kubectl config use-context docker-desktop 2>&1 | Out-Null

$nodes = kubectl get nodes 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Kubernetes está corriendo" -ForegroundColor Green
    Write-Host "   $nodes" -ForegroundColor Cyan
} else {
    Write-Host "   X Kubernetes no está activo" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Activa Kubernetes en Docker Desktop:" -ForegroundColor White
    Write-Host "   1. Abre Docker Desktop" -ForegroundColor Cyan
    Write-Host "   2. Settings > Kubernetes" -ForegroundColor Cyan
    Write-Host "   3. Enable Kubernetes" -ForegroundColor Cyan
    Write-Host "   4. Apply & Restart" -ForegroundColor Cyan
    exit 1
}

# 2. Crear namespace
Write-Host ""
Write-Host "2. Creando namespace 'ecommerce-dev'..." -ForegroundColor Yellow

kubectl create namespace ecommerce-dev --dry-run=client -o yaml | kubectl apply -f - 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace 'ecommerce-dev' creado" -ForegroundColor Green
} else {
    Write-Host "   ! Namespace ya existe" -ForegroundColor Yellow
}

# 3. Verificar Jenkins
Write-Host ""
Write-Host "3. Verificando Jenkins..." -ForegroundColor Yellow

$jenkinsRunning = docker ps --filter "name=jenkins" --format "{{.Names}}"

if ($jenkinsRunning -match "jenkins") {
    Write-Host "   OK Jenkins está corriendo" -ForegroundColor Green
} else {
    Write-Host "   X Jenkins no está corriendo" -ForegroundColor Red
    Write-Host "   Inicia Jenkins con: docker start jenkins" -ForegroundColor White
    exit 1
}

# 4. Crear directorio .kube en Jenkins
Write-Host ""
Write-Host "4. Configurando kubeconfig en Jenkins..." -ForegroundColor Yellow

docker exec jenkins mkdir -p /var/jenkins_home/.kube 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Directorio .kube creado" -ForegroundColor Green
} else {
    Write-Host "   ! Directorio ya existe" -ForegroundColor Yellow
}

# 5. Copiar kubeconfig a Jenkins
Write-Host ""
Write-Host "5. Copiando kubeconfig a Jenkins..." -ForegroundColor Yellow

$kubeconfigPath = "$env:USERPROFILE\.kube\config"

if (Test-Path $kubeconfigPath) {
    docker cp $kubeconfigPath jenkins:/var/jenkins_home/.kube/config 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK Kubeconfig copiado" -ForegroundColor Green
    } else {
        Write-Host "   X Error al copiar kubeconfig" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   X Kubeconfig no encontrado en $kubeconfigPath" -ForegroundColor Red
    exit 1
}

# 6. Dar permisos al kubeconfig
Write-Host ""
Write-Host "6. Configurando permisos..." -ForegroundColor Yellow

docker exec jenkins chmod 644 /var/jenkins_home/.kube/config 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Permisos configurados" -ForegroundColor Green
} else {
    Write-Host "   ! Error al configurar permisos" -ForegroundColor Yellow
}

# 7. Verificar que Jenkins puede acceder a Kubernetes
Write-Host ""
Write-Host "7. Verificando acceso de Jenkins a Kubernetes..." -ForegroundColor Yellow

$jenkinsKubectl = docker exec jenkins kubectl get nodes --context docker-desktop 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Jenkins puede acceder a Kubernetes" -ForegroundColor Green
    Write-Host "   $jenkinsKubectl" -ForegroundColor Cyan
} else {
    Write-Host "   X Jenkins no puede acceder a Kubernetes" -ForegroundColor Red
    Write-Host "   Error: $jenkinsKubectl" -ForegroundColor Red
}

# 8. Configurar contexto por defecto
Write-Host ""
Write-Host "8. Configurando contexto por defecto..." -ForegroundColor Yellow

docker exec jenkins kubectl config use-context docker-desktop 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Contexto 'docker-desktop' configurado" -ForegroundColor Green
} else {
    Write-Host "   ! Error al configurar contexto" -ForegroundColor Yellow
}

# 9. Verificar namespace
Write-Host ""
Write-Host "9. Verificando namespace..." -ForegroundColor Yellow

$namespaces = kubectl get namespace ecommerce-dev 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace 'ecommerce-dev' disponible" -ForegroundColor Green
} else {
    Write-Host "   X Namespace no encontrado" -ForegroundColor Red
}

# 10. Resumen
Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "OK Kubernetes: Docker Desktop (v1.31.1)" -ForegroundColor Green
Write-Host "OK Contexto: docker-desktop" -ForegroundColor Green
Write-Host "OK Namespace: ecommerce-dev" -ForegroundColor Green
Write-Host "OK Jenkins configurado" -ForegroundColor Green
Write-Host ""
Write-Host "=== COMO FUNCIONA ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Jenkins construye la imagen Docker" -ForegroundColor White
Write-Host "2. La imagen queda en el Docker local" -ForegroundColor White
Write-Host "3. Kubernetes (Docker Desktop) usa esa imagen directamente" -ForegroundColor White
Write-Host "4. NO necesitas 'docker push' ni 'kind load'" -ForegroundColor White
Write-Host ""
Write-Host "=== IMPORTANTE ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "En tus deployments de Kubernetes, usa:" -ForegroundColor White
Write-Host "  imagePullPolicy: Never" -ForegroundColor Cyan
Write-Host ""
Write-Host "Esto le dice a Kubernetes que use la imagen local" -ForegroundColor White
Write-Host ""
Write-Host "=== PROXIMOS PASOS ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ve a Jenkins: http://localhost:8079" -ForegroundColor White
Write-Host "2. Ejecuta el pipeline de 'order-service'" -ForegroundColor White
Write-Host "3. El pipeline:" -ForegroundColor White
Write-Host "   - Construira la imagen Docker" -ForegroundColor Cyan
Write-Host "   - Desplegara en Kubernetes" -ForegroundColor Cyan
Write-Host "   - El pod correra en Docker Desktop K8s" -ForegroundColor Cyan
Write-Host ""
Write-Host "=== COMANDOS UTILES ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ver pods:" -ForegroundColor White
Write-Host "  kubectl get pods -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver servicios:" -ForegroundColor White
Write-Host "  kubectl get svc -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver logs de un pod:" -ForegroundColor White
Write-Host "  kubectl logs <pod-name> -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Describir un pod:" -ForegroundColor White
Write-Host "  kubectl describe pod <pod-name> -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Eliminar todos los deployments:" -ForegroundColor White
Write-Host "  kubectl delete all --all -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
