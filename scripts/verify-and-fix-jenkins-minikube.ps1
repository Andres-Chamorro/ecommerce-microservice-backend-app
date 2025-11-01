# Script para verificar y configurar Jenkins-Minikube
Write-Host "=== Verificación Jenkins-Minikube ===" -ForegroundColor Green

# 1. Verificar que ambos contenedores estén corriendo
Write-Host "`n1. Verificando contenedores..." -ForegroundColor Yellow
$minikube = docker ps --filter "name=minikube" --format "{{.Names}}"
$jenkins = docker ps --filter "name=jenkins" --format "{{.Names}}"

if ($minikube -eq "minikube") {
    Write-Host "✓ Minikube está corriendo" -ForegroundColor Green
} else {
    Write-Host "✗ Minikube NO está corriendo" -ForegroundColor Red
    exit 1
}

if ($jenkins -eq "jenkins") {
    Write-Host "✓ Jenkins está corriendo" -ForegroundColor Green
} else {
    Write-Host "✗ Jenkins NO está corriendo" -ForegroundColor Red
    exit 1
}

# 2. Obtener IPs
Write-Host "`n2. Obteniendo direcciones IP..." -ForegroundColor Yellow
$minikubeIP = docker inspect minikube --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | Select-Object -First 1
$jenkinsIPs = docker inspect jenkins --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

Write-Host "Minikube IP: $minikubeIP" -ForegroundColor Cyan
Write-Host "Jenkins IPs: $jenkinsIPs" -ForegroundColor Cyan

# 3. Verificar conectividad desde Jenkins a Minikube
Write-Host "`n3. Verificando conectividad Jenkins -> Minikube..." -ForegroundColor Yellow

# Probar conexión al puerto Docker (2376)
Write-Host "Probando puerto Docker 2376..." -ForegroundColor White
docker exec jenkins sh -c "nc -zv $minikubeIP 2376 2>&1" | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Puerto Docker 2376 accesible" -ForegroundColor Green
} else {
    Write-Host "✗ Puerto Docker 2376 NO accesible" -ForegroundColor Red
}

# Probar conexión al puerto Kubernetes (8443)
Write-Host "Probando puerto Kubernetes 8443..." -ForegroundColor White
docker exec jenkins sh -c "nc -zv $minikubeIP 8443 2>&1" | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Puerto Kubernetes 8443 accesible" -ForegroundColor Green
} else {
    Write-Host "✗ Puerto Kubernetes 8443 NO accesible" -ForegroundColor Red
}

# 4. Configurar kubeconfig en Jenkins
Write-Host "`n4. Configurando kubeconfig en Jenkins..." -ForegroundColor Yellow

# Crear directorio .kube si no existe
docker exec jenkins mkdir -p /var/jenkins_home/.kube

# Obtener el kubeconfig actual y modificarlo para usar la IP interna
$kubeconfigContent = @"
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://${minikubeIP}:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /var/jenkins_home/.minikube/profiles/minikube/client.crt
    client-key: /var/jenkins_home/.minikube/profiles/minikube/client.key
"@

# Guardar temporalmente
$kubeconfigContent | Out-File -FilePath "temp-kubeconfig" -Encoding UTF8

# Copiar a Jenkins
docker cp temp-kubeconfig jenkins:/var/jenkins_home/.kube/config

# Limpiar archivo temporal
Remove-Item temp-kubeconfig

Write-Host "✓ Kubeconfig configurado" -ForegroundColor Green

# 5. Copiar certificados de Minikube a Jenkins
Write-Host "`n5. Copiando certificados de Minikube a Jenkins..." -ForegroundColor Yellow

# Crear directorio para certificados
docker exec jenkins mkdir -p /var/jenkins_home/.minikube/profiles/minikube

# Copiar certificados desde Minikube
docker exec minikube cat /var/lib/minikube/certs/client.crt > temp-client.crt
docker cp temp-client.crt jenkins:/var/jenkins_home/.minikube/profiles/minikube/client.crt
Remove-Item temp-client.crt

docker exec minikube cat /var/lib/minikube/certs/client.key > temp-client.key
docker cp temp-client.key jenkins:/var/jenkins_home/.minikube/profiles/minikube/client.key
Remove-Item temp-client.key

docker exec minikube cat /var/lib/minikube/certs/ca.crt > temp-ca.crt
docker cp temp-ca.crt jenkins:/var/jenkins_home/.minikube/profiles/minikube/ca.crt
Remove-Item temp-ca.crt

Write-Host "✓ Certificados copiados" -ForegroundColor Green

# 6. Verificar que kubectl funciona desde Jenkins
Write-Host "`n6. Verificando kubectl desde Jenkins..." -ForegroundColor Yellow
docker exec jenkins kubectl cluster-info

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ kubectl funciona correctamente desde Jenkins" -ForegroundColor Green
} else {
    Write-Host "✗ kubectl NO funciona desde Jenkins" -ForegroundColor Red
}

# 7. Verificar acceso a Docker daemon de Minikube
Write-Host "`n7. Verificando acceso a Docker daemon de Minikube..." -ForegroundColor Yellow
docker exec jenkins sh -c "DOCKER_HOST=tcp://${minikubeIP}:2376 docker version" | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker daemon de Minikube accesible" -ForegroundColor Green
} else {
    Write-Host "⚠ Docker daemon requiere configuración adicional" -ForegroundColor Yellow
}

Write-Host "`n=== Verificación Completada ===" -ForegroundColor Green
Write-Host "`nResumen de configuración:" -ForegroundColor Cyan
Write-Host "- Minikube IP: $minikubeIP" -ForegroundColor White
Write-Host "- Kubernetes API: https://${minikubeIP}:8443" -ForegroundColor White
Write-Host "- Docker Daemon: tcp://${minikubeIP}:2376" -ForegroundColor White
Write-Host "`nPuedes probar el pipeline ahora en Jenkins" -ForegroundColor Green
