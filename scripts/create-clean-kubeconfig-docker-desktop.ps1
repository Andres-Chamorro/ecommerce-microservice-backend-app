# Script para crear un kubeconfig limpio solo para Docker Desktop

Write-Host "=== CREANDO KUBECONFIG LIMPIO PARA DOCKER DESKTOP ===" -ForegroundColor Cyan
Write-Host ""

# 1. Obtener información del cluster de Docker Desktop
Write-Host "1. Obteniendo información del cluster..." -ForegroundColor Yellow

kubectl config use-context docker-desktop 2>&1 | Out-Null

$clusterServer = kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>&1
$clusterCA = kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' 2>&1
$clientCert = kubectl config view --minify --raw -o jsonpath='{.users[0].user.client-certificate-data}' 2>&1
$clientKey = kubectl config view --minify --raw -o jsonpath='{.users[0].user.client-key-data}' 2>&1

Write-Host "   Cluster Server: $clusterServer" -ForegroundColor Cyan
Write-Host "   OK Información obtenida" -ForegroundColor Green

# 2. Crear kubeconfig limpio
Write-Host ""
Write-Host "2. Creando kubeconfig limpio..." -ForegroundColor Yellow

$cleanKubeconfig = @"
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $clusterCA
    server: $clusterServer
  name: docker-desktop
contexts:
- context:
    cluster: docker-desktop
    user: docker-desktop
  name: docker-desktop
current-context: docker-desktop
users:
- name: docker-desktop
  user:
    client-certificate-data: $clientCert
    client-key-data: $clientKey
"@

# 3. Guardar en archivo temporal
$tempKubeconfig = "$env:TEMP\kubeconfig-docker-desktop"
$cleanKubeconfig | Out-File -FilePath $tempKubeconfig -Encoding UTF8

Write-Host "   OK Kubeconfig limpio creado" -ForegroundColor Green

# 4. Copiar a Jenkins
Write-Host ""
Write-Host "3. Copiando a Jenkins..." -ForegroundColor Yellow

# Backup del anterior
docker exec jenkins cp /var/jenkins_home/.kube/config /var/jenkins_home/.kube/config.old 2>&1 | Out-Null

# Copiar el nuevo
docker cp $tempKubeconfig jenkins:/var/jenkins_home/.kube/config 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Kubeconfig copiado a Jenkins" -ForegroundColor Green
} else {
    Write-Host "   X Error al copiar" -ForegroundColor Red
    exit 1
}

# 5. Dar permisos
docker exec jenkins chmod 644 /var/jenkins_home/.kube/config 2>&1 | Out-Null

# 6. Verificar
Write-Host ""
Write-Host "4. Verificando acceso desde Jenkins..." -ForegroundColor Yellow

$jenkinsNodes = docker exec jenkins kubectl get nodes 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK Jenkins puede acceder a Kubernetes" -ForegroundColor Green
    Write-Host "$jenkinsNodes" -ForegroundColor Cyan
} else {
    Write-Host "   X Error al acceder" -ForegroundColor Red
    Write-Host "$jenkinsNodes" -ForegroundColor Red
    exit 1
}

# 7. Crear namespace
Write-Host ""
Write-Host "5. Verificando namespace..." -ForegroundColor Yellow

docker exec jenkins kubectl create namespace ecommerce-dev --dry-run=client -o yaml 2>&1 | docker exec -i jenkins kubectl apply -f - 2>&1 | Out-Null

Write-Host "   OK Namespace 'ecommerce-dev' listo" -ForegroundColor Green

# 8. Limpiar archivo temporal
Remove-Item $tempKubeconfig -Force

# 9. Resumen final
Write-Host ""
Write-Host "=== CONFIGURACION COMPLETADA ===" -ForegroundColor Green
Write-Host ""
Write-Host "OK Kubeconfig limpio creado" -ForegroundColor Green
Write-Host "OK Jenkins conectado a Docker Desktop Kubernetes" -ForegroundColor Green
Write-Host "OK Namespace 'ecommerce-dev' disponible" -ForegroundColor Green
Write-Host ""
Write-Host "=== PRUEBA RAPIDA ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta este comando para verificar:" -ForegroundColor White
Write-Host "  docker exec jenkins kubectl get pods -n ecommerce-dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "=== LISTO PARA JENKINS ===" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora puedes ejecutar pipelines en Jenkins" -ForegroundColor White
Write-Host "Ve a: http://localhost:8079" -ForegroundColor Cyan
Write-Host ""
