# Script para crear un kubeconfig limpio solo para Minikube

Write-Host "Creando kubeconfig limpio para Minikube..." -ForegroundColor Cyan

# 1. Obtener la IP del contenedor Minikube
Write-Host "`nObteniendo IP de Minikube..." -ForegroundColor Yellow
$minikubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minikube
Write-Host "IP de Minikube: $minikubeIP" -ForegroundColor Green

# 2. Obtener los certificados en base64
Write-Host "`nObteniendo certificados..." -ForegroundColor Yellow
$caCert = docker exec minikube sh -c "cat /var/lib/minikube/certs/ca.crt | base64 -w 0"
$clientCert = docker exec minikube sh -c "cat /var/lib/minikube/certs/apiserver.crt | base64 -w 0"
$clientKey = docker exec minikube sh -c "cat /var/lib/minikube/certs/apiserver.key | base64 -w 0"

# 3. Crear el archivo kubeconfig
Write-Host "`nCreando archivo kubeconfig..." -ForegroundColor Yellow
$kubeconfigYaml = @"
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $caCert
    server: https://${minikubeIP}:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
users:
- name: minikube
  user:
    client-certificate-data: $clientCert
    client-key-data: $clientKey
"@

# 4. Guardar en archivo temporal
$kubeconfigYaml | Out-File -FilePath "temp-clean-kubeconfig.yaml" -Encoding UTF8 -NoNewline

# 5. Copiar a Jenkins
Write-Host "`nCopiando kubeconfig a Jenkins..." -ForegroundColor Yellow
Get-Content temp-clean-kubeconfig.yaml -Raw | docker exec -i jenkins sh -c "cat > /var/jenkins_home/.kube/config"

# 6. Configurar permisos
Write-Host "`nConfigurando permisos..." -ForegroundColor Yellow
docker exec jenkins sh -c "chmod 600 /var/jenkins_home/.kube/config"
docker exec jenkins sh -c "chown jenkins:jenkins /var/jenkins_home/.kube/config"

# 7. Verificar
Write-Host "`nVerificando configuracion..." -ForegroundColor Yellow
docker exec jenkins kubectl config view --minify

Write-Host "`nContexto actual:" -ForegroundColor Yellow
docker exec jenkins kubectl config current-context

Write-Host "`nProbando conexion..." -ForegroundColor Yellow
docker exec jenkins kubectl cluster-info

# 8. Limpiar
Remove-Item temp-clean-kubeconfig.yaml -ErrorAction SilentlyContinue

Write-Host "`nConfiguracion completada exitosamente!" -ForegroundColor Green
