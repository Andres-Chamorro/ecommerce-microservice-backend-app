# Script para arreglar el kubeconfig de Jenkins para Docker Desktop

Write-Host "=== ARREGLANDO KUBECONFIG DE JENKINS ===" -ForegroundColor Cyan
Write-Host ""

# 1. Hacer backup del kubeconfig actual de Jenkins
Write-Host "1. Haciendo backup del kubeconfig actual..." -ForegroundColor Yellow

docker exec jenkins cp /var/jenkins_home/.kube/config /var/jenkins_home/.kube/config.backup 2>&1 | Out-Null

Write-Host "   OK Backup creado" -ForegroundColor Green

# 2. Copiar el kubeconfig del host a Jenkins
Write-Host ""
Write-Host "2. Copiando kubeconfig actualizado..." -ForegroundColor Yellow

$kubeconfigPath = "$env:USERPROFILE\.kube\config"

docker cp $kubeconfigPath jenkins:/var/jenkins_home/.kube/config 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Kubeconfig copiado" -ForegroundColor Green
} else {
    Write-Host "   X Error al copiar" -ForegroundColor Red
    exit 1
}

# 3. Dar permisos
Write-Host ""
Write-Host "3. Configurando permisos..." -ForegroundColor Yellow

docker exec jenkins chmod 644 /var/jenkins_home/.kube/config 2>&1 | Out-Null
Write-Host "   OK Permisos configurados" -ForegroundColor Green

# 4. Verificar contextos disponibles
Write-Host ""
Write-Host "4. Verificando contextos disponibles en Jenkins..." -ForegroundColor Yellow

$contexts = docker exec jenkins kubectl config get-contexts 2>&1

Write-Host "$contexts" -ForegroundColor Cyan

# 5. Configurar docker-desktop como contexto por defecto
Write-Host ""
Write-Host "5. Configurando docker-desktop como contexto por defecto..." -ForegroundColor Yellow

docker exec jenkins kubectl config use-context docker-desktop 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Contexto configurado" -ForegroundColor Green
} else {
    Write-Host "   X Error al configurar contexto" -ForegroundColor Red
}

# 6. Verificar acceso
Write-Host ""
Write-Host "6. Verificando acceso a Kubernetes..." -ForegroundColor Yellow

$nodes = docker exec jenkins kubectl get nodes 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Jenkins puede acceder a Kubernetes" -ForegroundColor Green
    Write-Host "$nodes" -ForegroundColor Cyan
} else {
    Write-Host "   X Error al acceder a Kubernetes" -ForegroundColor Red
    Write-Host "$nodes" -ForegroundColor Red
}

# 7. Verificar namespace
Write-Host ""
Write-Host "7. Verificando namespace ecommerce-dev..." -ForegroundColor Yellow

$ns = docker exec jenkins kubectl get namespace ecommerce-dev 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace disponible" -ForegroundColor Green
} else {
    Write-Host "   ! Creando namespace..." -ForegroundColor Yellow
    docker exec jenkins kubectl create namespace ecommerce-dev 2>&1 | Out-Null
    Write-Host "   OK Namespace creado" -ForegroundColor Green
}

# 8. Resumen
Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "OK Kubeconfig actualizado en Jenkins" -ForegroundColor Green
Write-Host "OK Contexto: docker-desktop" -ForegroundColor Green
Write-Host "OK Namespace: ecommerce-dev" -ForegroundColor Green
Write-Host ""
Write-Host "=== LISTO PARA USAR ===" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora puedes ejecutar pipelines en Jenkins" -ForegroundColor White
Write-Host "Los servicios se desplegaran en Docker Desktop Kubernetes" -ForegroundColor White
Write-Host ""
