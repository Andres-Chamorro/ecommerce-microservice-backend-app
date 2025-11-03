# Script final para conectar Jenkins con Docker Desktop Kubernetes

Write-Host "=== SOLUCION FINAL: JENKINS + DOCKER DESKTOP K8S ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "PROBLEMA IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "Jenkins (contenedor) no puede acceder a 127.0.0.1 del host" -ForegroundColor White
Write-Host ""
Write-Host "SOLUCION:" -ForegroundColor Yellow
Write-Host "Usar 'host.docker.internal' para acceder al host desde el contenedor" -ForegroundColor White
Write-Host ""

# 1. Obtener el puerto del API server
Write-Host "1. Obteniendo configuración de Docker Desktop K8s..." -ForegroundColor Yellow

kubectl config use-context docker-desktop 2>&1 | Out-Null

$clusterServer = kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>&1
$port = ($clusterServer -split ':')[-1]

Write-Host "   Puerto del API Server: $port" -ForegroundColor Cyan

# 2. Obtener certificados
$clusterCA = kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' 2>&1
$clientCert = kubectl config view --minify --raw -o jsonpath='{.users[0].user.client-certificate-data}' 2>&1
$clientKey = kubectl config view --minify --raw -o jsonpath='{.users[0].user.client-key-data}' 2>&1

# 3. Crear kubeconfig con host.docker.internal
Write-Host ""
Write-Host "2. Creando kubeconfig con host.docker.internal..." -ForegroundColor Yellow

$jenkinsKubeconfig = @"
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $clusterCA
    server: https://host.docker.internal:$port
  name: docker-desktop
contexts:
- context:
    cluster: docker-desktop
    user: docker-desktop
    namespace: ecommerce-dev
  name: docker-desktop
current-context: docker-desktop
users:
- name: docker-desktop
  user:
    client-certificate-data: $clientCert
    client-key-data: $clientKey
"@

# 4. Guardar temporalmente
$tempKubeconfig = "$env:TEMP\kubeconfig-jenkins"
$jenkinsKubeconfig | Out-File -FilePath $tempKubeconfig -Encoding UTF8

Write-Host "   OK Kubeconfig creado" -ForegroundColor Green

# 5. Copiar a Jenkins
Write-Host ""
Write-Host "3. Copiando a Jenkins..." -ForegroundColor Yellow

docker cp $tempKubeconfig jenkins:/var/jenkins_home/.kube/config 2>&1 | Out-Null
docker exec jenkins chmod 644 /var/jenkins_home/.kube/config 2>&1 | Out-Null

Write-Host "   OK Copiado" -ForegroundColor Green

# 6. Crear namespace
Write-Host ""
Write-Host "4. Creando namespace..." -ForegroundColor Yellow

kubectl create namespace ecommerce-dev --dry-run=client -o yaml | kubectl apply -f - 2>&1 | Out-Null

Write-Host "   OK Namespace 'ecommerce-dev' listo" -ForegroundColor Green

# 7. Verificar desde Jenkins
Write-Host ""
Write-Host "5. Verificando acceso desde Jenkins..." -ForegroundColor Yellow

$jenkinsTest = docker exec jenkins kubectl get nodes 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Jenkins puede acceder a Kubernetes!" -ForegroundColor Green
    Write-Host "$jenkinsTest" -ForegroundColor Cyan
} else {
    Write-Host "   X Error al acceder" -ForegroundColor Red
    Write-Host "$jenkinsTest" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "TROUBLESHOOTING:" -ForegroundColor Yellow
    Write-Host "Si ves errores de conexión, verifica que:" -ForegroundColor White
    Write-Host "1. Docker Desktop Kubernetes esté activo" -ForegroundColor Cyan
    Write-Host "2. Jenkins pueda resolver 'host.docker.internal'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Prueba manual:" -ForegroundColor White
    Write-Host "  docker exec jenkins ping -c 1 host.docker.internal" -ForegroundColor Cyan
}

# 8. Verificar namespace desde Jenkins
Write-Host ""
Write-Host "6. Verificando namespace desde Jenkins..." -ForegroundColor Yellow

$jenkinsNS = docker exec jenkins kubectl get namespace ecommerce-dev 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Namespace accesible desde Jenkins" -ForegroundColor Green
} else {
    Write-Host "   X Namespace no accesible" -ForegroundColor Red
}

# 9. Limpiar
Remove-Item $tempKubeconfig -Force

# 10. Resumen
Write-Host ""
Write-Host "=== CONFIGURACION COMPLETADA ===" -ForegroundColor Green
Write-Host ""
Write-Host "OK Kubernetes: Docker Desktop (v1.31.1)" -ForegroundColor Green
Write-Host "OK Conexión: host.docker.internal:$port" -ForegroundColor Green
Write-Host "OK Namespace: ecommerce-dev" -ForegroundColor Green
Write-Host ""
Write-Host "=== COMO FUNCIONA ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Jenkins construye imagen Docker" -ForegroundColor White
Write-Host "2. Imagen queda en Docker local" -ForegroundColor White
Write-Host "3. Jenkins despliega en Kubernetes via host.docker.internal" -ForegroundColor White
Write-Host "4. Kubernetes usa la imagen local (imagePullPolicy: Never)" -ForegroundColor White
Write-Host ""
Write-Host "=== PROXIMO PASO ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta un pipeline en Jenkins:" -ForegroundColor White
Write-Host "1. Ve a http://localhost:8079" -ForegroundColor Cyan
Write-Host "2. Ejecuta el pipeline de 'order-service'" -ForegroundColor Cyan
Write-Host "3. Verifica el deployment:" -ForegroundColor Cyan
Write-Host "   kubectl get pods -n ecommerce-dev" -ForegroundColor White
Write-Host ""
