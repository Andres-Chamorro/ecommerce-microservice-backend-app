# Script completo para configurar Jenkins + Minikube
# Este script verifica y configura todo lo necesario

Write-Host "=== CONFIGURACION JENKINS + MINIKUBE ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Minikube
Write-Host "1. Verificando Minikube..." -ForegroundColor Yellow
$minikubeExists = Get-Command minikube -ErrorAction SilentlyContinue

if (-not $minikubeExists) {
    Write-Host "   X Minikube no esta instalado o no esta en PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Para instalar Minikube:" -ForegroundColor White
    Write-Host "   1. Descarga desde: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor White
    Write-Host "   2. O usa Chocolatey: choco install minikube" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "   OK Minikube encontrado" -ForegroundColor Green

# 2. Verificar estado de Minikube
Write-Host ""
Write-Host "2. Verificando estado de Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>&1

if ($minikubeStatus -match "Running") {
    Write-Host "   OK Minikube esta corriendo" -ForegroundColor Green
    $minikubeIP = minikube ip
    Write-Host "   IP de Minikube: $minikubeIP" -ForegroundColor Cyan
} else {
    Write-Host "   ! Minikube no esta corriendo" -ForegroundColor Yellow
    Write-Host "   Iniciando Minikube..." -ForegroundColor Yellow
    
    minikube start --driver=docker
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK Minikube iniciado correctamente" -ForegroundColor Green
        $minikubeIP = minikube ip
        Write-Host "   IP de Minikube: $minikubeIP" -ForegroundColor Cyan
    } else {
        Write-Host "   X Error al iniciar Minikube" -ForegroundColor Red
        exit 1
    }
}

# 3. Obtener informacion de conexion
Write-Host ""
Write-Host "3. Obteniendo informacion de conexion..." -ForegroundColor Yellow

$minikubeIP = minikube ip
$kubeContext = kubectl config current-context

Write-Host "   IP de Minikube: $minikubeIP" -ForegroundColor Cyan
Write-Host "   Contexto actual: $kubeContext" -ForegroundColor Cyan

# 4. Verificar conectividad
Write-Host ""
Write-Host "4. Verificando conectividad con Kubernetes..." -ForegroundColor Yellow

$clusterInfo = kubectl cluster-info 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Conexion exitosa con Kubernetes" -ForegroundColor Green
} else {
    Write-Host "   X No se puede conectar con Kubernetes" -ForegroundColor Red
    Write-Host "   $clusterInfo" -ForegroundColor Red
    exit 1
}

# 5. Verificar Docker daemon de Minikube
Write-Host ""
Write-Host "5. Configurando acceso al Docker de Minikube..." -ForegroundColor Yellow

# Obtener variables de entorno de Docker
$dockerEnv = minikube docker-env --shell powershell | Out-String

Write-Host "   OK Variables de Docker obtenidas" -ForegroundColor Green
Write-Host ""
Write-Host "   Para usar el Docker de Minikube en esta sesion, ejecuta:" -ForegroundColor Cyan
Write-Host "   minikube docker-env --shell powershell | Invoke-Expression" -ForegroundColor White

# 6. Crear namespace para desarrollo
Write-Host ""
Write-Host "6. Creando namespace 'ecommerce-dev'..." -ForegroundColor Yellow

kubectl create namespace ecommerce-dev --dry-run=client -o yaml | kubectl apply -f - 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace 'ecommerce-dev' listo" -ForegroundColor Green
} else {
    Write-Host "   ! Namespace ya existe o error al crear" -ForegroundColor Yellow
}

# 7. Verificar Jenkins
Write-Host ""
Write-Host "7. Verificando Jenkins..." -ForegroundColor Yellow

$jenkinsRunning = docker ps --filter "name=jenkins" --format "{{.Names}}" 2>&1

if ($jenkinsRunning -match "jenkins") {
    Write-Host "   OK Jenkins esta corriendo" -ForegroundColor Green
    
    # Verificar si Jenkins puede acceder a kubectl
    Write-Host ""
    Write-Host "8. Verificando acceso de Jenkins a kubectl..." -ForegroundColor Yellow
    
    $kubectlInJenkins = docker exec jenkins kubectl version --client 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK kubectl disponible en Jenkins" -ForegroundColor Green
    } else {
        Write-Host "   X kubectl NO disponible en Jenkins" -ForegroundColor Red
        Write-Host "   Necesitas instalar kubectl en el contenedor Jenkins" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ! Jenkins no esta corriendo" -ForegroundColor Yellow
    Write-Host "   Inicia Jenkins con: docker start jenkins" -ForegroundColor White
}

# 9. Resumen y proximos pasos
Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "OK Minikube IP: $minikubeIP" -ForegroundColor Green
Write-Host "OK Kubernetes Context: $kubeContext" -ForegroundColor Green
Write-Host "OK Namespace: ecommerce-dev" -ForegroundColor Green
Write-Host ""
Write-Host "=== PROXIMOS PASOS ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Para que Jenkins use el Docker de Minikube:" -ForegroundColor White
Write-Host "   - Jenkins debe usar: minikube docker-env" -ForegroundColor Cyan
Write-Host "   - O construir imagenes con: docker build dentro de Minikube" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Para que Jenkins acceda a Kubernetes:" -ForegroundColor White
Write-Host "   - Copiar kubeconfig a Jenkins:" -ForegroundColor Cyan
$kubeconfigPath = "$env:USERPROFILE\.kube\config"
Write-Host "     docker cp $kubeconfigPath jenkins:/var/jenkins_home/.kube/config" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Ejecutar un pipeline de prueba en Jenkins" -ForegroundColor White
Write-Host ""
Write-Host "=== COMANDOS UTILES ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ver pods en Minikube:" -ForegroundColor White
Write-Host "  kubectl get pods -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver imagenes en Minikube:" -ForegroundColor White
Write-Host "  minikube ssh docker images" -ForegroundColor Cyan
Write-Host ""
Write-Host "Acceder al dashboard de Minikube:" -ForegroundColor White
Write-Host "  minikube dashboard" -ForegroundColor Cyan
Write-Host ""
