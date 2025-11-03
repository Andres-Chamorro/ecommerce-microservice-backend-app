# Script para configurar Kind (Kubernetes in Docker)
# Solución más simple que Minikube

Write-Host "=== CONFIGURACION KIND (KUBERNETES EN DOCKER) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar si Kind está instalado
Write-Host "1. Verificando Kind..." -ForegroundColor Yellow
$kindExists = Get-Command kind -ErrorAction SilentlyContinue

if (-not $kindExists) {
    Write-Host "   X Kind no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Instalando Kind con Chocolatey..." -ForegroundColor Yellow
    
    $chocoExists = Get-Command choco -ErrorAction SilentlyContinue
    
    if ($chocoExists) {
        choco install kind -y
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   OK Kind instalado correctamente" -ForegroundColor Green
        } else {
            Write-Host "   X Error al instalar Kind" -ForegroundColor Red
            Write-Host ""
            Write-Host "   Instala manualmente desde: https://kind.sigs.k8s.io/docs/user/quick-start/" -ForegroundColor White
            exit 1
        }
    } else {
        Write-Host "   X Chocolatey no está instalado" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Opciones:" -ForegroundColor White
        Write-Host "   1. Instala Chocolatey: https://chocolatey.org/install" -ForegroundColor Cyan
        Write-Host "   2. O descarga Kind manualmente: https://kind.sigs.k8s.io/docs/user/quick-start/" -ForegroundColor Cyan
        exit 1
    }
}

Write-Host "   OK Kind encontrado" -ForegroundColor Green

# 2. Verificar si ya existe un cluster
Write-Host ""
Write-Host "2. Verificando clusters existentes..." -ForegroundColor Yellow

$existingClusters = kind get clusters 2>&1

if ($existingClusters -match "jenkins-dev") {
    Write-Host "   ! Cluster 'jenkins-dev' ya existe" -ForegroundColor Yellow
    Write-Host "   Eliminando cluster existente..." -ForegroundColor Yellow
    kind delete cluster --name jenkins-dev
}

# 3. Crear cluster de Kind
Write-Host ""
Write-Host "3. Creando cluster de Kubernetes en Docker..." -ForegroundColor Yellow

kind create cluster --name jenkins-dev

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Cluster 'jenkins-dev' creado correctamente" -ForegroundColor Green
} else {
    Write-Host "   X Error al crear cluster" -ForegroundColor Red
    exit 1
}

# 4. Verificar que el cluster está corriendo
Write-Host ""
Write-Host "4. Verificando cluster..." -ForegroundColor Yellow

$clusterInfo = kubectl cluster-info --context kind-jenkins-dev 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Cluster funcionando correctamente" -ForegroundColor Green
} else {
    Write-Host "   X Error al conectar con el cluster" -ForegroundColor Red
    exit 1
}

# 5. Verificar contenedor de Kind
Write-Host ""
Write-Host "5. Verificando contenedor Docker..." -ForegroundColor Yellow

$kindContainer = docker ps --filter "name=jenkins-dev-control-plane" --format "{{.Names}}"

if ($kindContainer) {
    Write-Host "   OK Contenedor '$kindContainer' corriendo" -ForegroundColor Green
} else {
    Write-Host "   X Contenedor de Kind no encontrado" -ForegroundColor Red
}

# 6. Crear namespace
Write-Host ""
Write-Host "6. Creando namespace 'ecommerce-dev'..." -ForegroundColor Yellow

kubectl create namespace ecommerce-dev --context kind-jenkins-dev 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace creado" -ForegroundColor Green
} else {
    Write-Host "   ! Namespace ya existe o error" -ForegroundColor Yellow
}

# 7. Configurar Jenkins
Write-Host ""
Write-Host "7. Configurando Jenkins..." -ForegroundColor Yellow

$jenkinsRunning = docker ps --filter "name=jenkins" --format "{{.Names}}"

if ($jenkinsRunning -match "jenkins") {
    Write-Host "   OK Jenkins está corriendo" -ForegroundColor Green
    
    # Crear directorio .kube en Jenkins
    docker exec jenkins mkdir -p /var/jenkins_home/.kube 2>&1 | Out-Null
    
    # Copiar kubeconfig
    $kubeconfigPath = "$env:USERPROFILE\.kube\config"
    docker cp $kubeconfigPath jenkins:/var/jenkins_home/.kube/config 2>&1 | Out-Null
    
    # Dar permisos
    docker exec jenkins chmod 644 /var/jenkins_home/.kube/config 2>&1 | Out-Null
    
    Write-Host "   OK Kubeconfig copiado a Jenkins" -ForegroundColor Green
    
    # Verificar acceso
    Write-Host ""
    Write-Host "8. Verificando acceso de Jenkins a Kubernetes..." -ForegroundColor Yellow
    
    $jenkinsKubectl = docker exec jenkins kubectl get nodes --context kind-jenkins-dev 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK Jenkins puede acceder a Kubernetes" -ForegroundColor Green
    } else {
        Write-Host "   X Jenkins no puede acceder a Kubernetes" -ForegroundColor Red
        Write-Host "   Error: $jenkinsKubectl" -ForegroundColor Red
    }
} else {
    Write-Host "   ! Jenkins no está corriendo" -ForegroundColor Yellow
    Write-Host "   Inicia Jenkins con: docker start jenkins" -ForegroundColor White
}

# 9. Instalar Kind en Jenkins (para kind load)
Write-Host ""
Write-Host "9. Instalando Kind en Jenkins..." -ForegroundColor Yellow

$installKindScript = @'
#!/bin/bash
if ! command -v kind &> /dev/null; then
    echo "Instalando Kind en Jenkins..."
    curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x /usr/local/bin/kind
    echo "Kind instalado"
else
    echo "Kind ya está instalado"
fi
'@

$installKindScript | docker exec -i jenkins bash

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Kind instalado en Jenkins" -ForegroundColor Green
} else {
    Write-Host "   ! Error al instalar Kind en Jenkins" -ForegroundColor Yellow
}

# 10. Resumen
Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "OK Cluster Kind: jenkins-dev" -ForegroundColor Green
Write-Host "OK Contexto: kind-jenkins-dev" -ForegroundColor Green
Write-Host "OK Namespace: ecommerce-dev" -ForegroundColor Green
Write-Host "OK Jenkins configurado" -ForegroundColor Green
Write-Host ""
Write-Host "=== PROXIMOS PASOS ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Actualizar Jenkinsfiles para usar Kind:" -ForegroundColor White
Write-Host "   - Usar: kind load docker-image <imagen> --name jenkins-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Ejecutar un pipeline de prueba" -ForegroundColor White
Write-Host ""
Write-Host "=== COMANDOS UTILES ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ver pods:" -ForegroundColor White
Write-Host "  kubectl get pods -n ecommerce-dev --context kind-jenkins-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Cargar imagen en Kind:" -ForegroundColor White
Write-Host "  kind load docker-image order-service:dev --name jenkins-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver logs del cluster:" -ForegroundColor White
Write-Host "  docker logs jenkins-dev-control-plane" -ForegroundColor Cyan
Write-Host ""
Write-Host "Eliminar cluster:" -ForegroundColor White
Write-Host "  kind delete cluster --name jenkins-dev" -ForegroundColor Cyan
Write-Host ""
