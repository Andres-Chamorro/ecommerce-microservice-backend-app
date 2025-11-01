# Script para configurar Minikube con API insegura (sin TLS)
Write-Host "=== Configurando Minikube sin TLS ===" -ForegroundColor Green

# 1. Obtener IP de Minikube
Write-Host "`n1. Obteniendo IP de Minikube..." -ForegroundColor Yellow
$minikubeIP = docker inspect minikube --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | Select-Object -First 1
Write-Host "Minikube IP: $minikubeIP" -ForegroundColor Cyan

# 2. Habilitar puerto inseguro en kube-apiserver
Write-Host "`n2. Configurando kube-apiserver para puerto inseguro..." -ForegroundColor Yellow

# Modificar el manifest del API server para agregar puerto inseguro
$apiServerConfig = @"
docker exec minikube sh -c 'cat > /tmp/patch-apiserver.sh << "EOF"
#!/bin/bash
# Agregar configuración insegura al API server
if ! grep -q "insecure-port" /etc/kubernetes/manifests/kube-apiserver.yaml; then
    sed -i "/- kube-apiserver/a\    - --insecure-port=8080" /etc/kubernetes/manifests/kube-apiserver.yaml
    sed -i "/- kube-apiserver/a\    - --insecure-bind-address=0.0.0.0" /etc/kubernetes/manifests/kube-apiserver.yaml
    echo "Configuración agregada"
else
    echo "Ya configurado"
fi
EOF
chmod +x /tmp/patch-apiserver.sh
/tmp/patch-apiserver.sh'
"@

Invoke-Expression $apiServerConfig

Write-Host "✓ Configuración aplicada" -ForegroundColor Green

# 3. Esperar a que el API server se reinicie
Write-Host "`n3. Esperando a que API server se reinicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 4. Verificar que el puerto 8080 esté disponible
Write-Host "`n4. Verificando puerto inseguro 8080..." -ForegroundColor Yellow
docker exec minikube sh -c "curl -s http://localhost:8080/healthz"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Puerto 8080 responde" -ForegroundColor Green
} else {
    Write-Host "⚠ Puerto 8080 no responde aún, puede necesitar más tiempo" -ForegroundColor Yellow
}

# 5. Configurar kubeconfig inseguro para Jenkins
Write-Host "`n5. Configurando kubeconfig inseguro en Jenkins..." -ForegroundColor Yellow

$kubeconfigInsecure = @"
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: http://${minikubeIP}:8080
  name: minikube-insecure
contexts:
- context:
    cluster: minikube-insecure
    user: minikube-insecure
  name: minikube-insecure
current-context: minikube-insecure
kind: Config
preferences: {}
users:
- name: minikube-insecure
  user: {}
"@

# Guardar temporalmente
$kubeconfigInsecure | Out-File -FilePath "temp-kubeconfig-insecure" -Encoding UTF8

# Copiar a Jenkins
docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp temp-kubeconfig-insecure jenkins:/var/jenkins_home/.kube/config

# Limpiar
Remove-Item temp-kubeconfig-insecure

Write-Host "✓ Kubeconfig inseguro configurado" -ForegroundColor Green

# 6. Verificar conectividad desde Jenkins
Write-Host "`n6. Verificando kubectl desde Jenkins..." -ForegroundColor Yellow
docker exec jenkins kubectl get nodes

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ kubectl funciona correctamente" -ForegroundColor Green
} else {
    Write-Host "✗ kubectl aún no funciona" -ForegroundColor Red
}

# 7. Configurar Docker daemon inseguro
Write-Host "`n7. Configurando Docker daemon sin TLS..." -ForegroundColor Yellow

docker exec minikube sh -c @"
cat > /tmp/configure-docker.sh << 'EOFSCRIPT'
#!/bin/bash
# Configurar Docker daemon para aceptar conexiones sin TLS
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOFJSON'
{
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"],
  "tls": false
}
EOFJSON

# Reiniciar Docker
systemctl restart docker 2>/dev/null || service docker restart 2>/dev/null || true
EOFSCRIPT
chmod +x /tmp/configure-docker.sh
/tmp/configure-docker.sh
"@

Write-Host "✓ Docker daemon configurado" -ForegroundColor Green

# 8. Verificar acceso a Docker desde Jenkins
Write-Host "`n8. Verificando Docker desde Jenkins..." -ForegroundColor Yellow
docker exec jenkins sh -c "DOCKER_HOST=tcp://${minikubeIP}:2376 docker version" 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker accesible desde Jenkins" -ForegroundColor Green
} else {
    Write-Host "⚠ Docker puede requerir configuración adicional" -ForegroundColor Yellow
}

Write-Host "`n=== Configuración Completada ===" -ForegroundColor Green
Write-Host "`nResumen:" -ForegroundColor Cyan
Write-Host "- Minikube IP: $minikubeIP" -ForegroundColor White
Write-Host "- Kubernetes API (inseguro): http://${minikubeIP}:8080" -ForegroundColor White
Write-Host "- Docker Daemon: tcp://${minikubeIP}:2376" -ForegroundColor White
Write-Host "`n⚠ ADVERTENCIA: Esta configuración es INSEGURA" -ForegroundColor Red
Write-Host "Solo usar para desarrollo local" -ForegroundColor Red
