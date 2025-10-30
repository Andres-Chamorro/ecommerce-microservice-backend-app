# Script para limpiar y configurar kubectl en Jenkins para usar solo Minikube
# Elimina cualquier referencia a GKE

Write-Host "Limpiando configuracion de kubectl en Jenkins..." -ForegroundColor Cyan

# 1. Obtener la IP del contenedor Minikube
Write-Host "`nObteniendo IP de Minikube..." -ForegroundColor Yellow
$minikubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minikube
Write-Host "IP de Minikube: $minikubeIP" -ForegroundColor Green

# 2. Hacer backup del kubeconfig actual
Write-Host "`nHaciendo backup del kubeconfig actual..." -ForegroundColor Yellow
docker exec jenkins sh -c "cp /var/jenkins_home/.kube/config /var/jenkins_home/.kube/config.backup.gke 2>/dev/null || true"

# 3. Copiar el kubeconfig de Minikube directamente
Write-Host "`nCopiando kubeconfig de Minikube..." -ForegroundColor Yellow
docker exec minikube cat /root/.kube/config > temp-minikube-config.yaml

# 4. Actualizar la IP del servidor en el kubeconfig
Write-Host "`nActualizando IP del servidor..." -ForegroundColor Yellow
$kubeconfigContent = Get-Content temp-minikube-config.yaml -Raw
$kubeconfigContent = $kubeconfigContent -replace 'https://.*:8443', "https://${minikubeIP}:8443"
$kubeconfigContent | Set-Content temp-minikube-config-fixed.yaml

# 5. Copiar el kubeconfig actualizado a Jenkins
Write-Host "`nCopiando kubeconfig a Jenkins..." -ForegroundColor Yellow
Get-Content temp-minikube-config-fixed.yaml | docker exec -i jenkins sh -c "cat > /var/jenkins_home/.kube/config"

# 6. Configurar permisos
Write-Host "`nConfigurando permisos..." -ForegroundColor Yellow
docker exec jenkins sh -c "chmod 600 /var/jenkins_home/.kube/config"
docker exec jenkins sh -c "chown jenkins:jenkins /var/jenkins_home/.kube/config"

# 7. Verificar la configuración
Write-Host "`nVerificando configuracion..." -ForegroundColor Yellow
docker exec jenkins kubectl config view
Write-Host "`nContexto actual:" -ForegroundColor Yellow
docker exec jenkins kubectl config current-context

Write-Host "`nProbando conexion..." -ForegroundColor Yellow
docker exec jenkins kubectl cluster-info

# 8. Limpiar archivos temporales
Remove-Item temp-minikube-config.yaml -ErrorAction SilentlyContinue
Remove-Item temp-minikube-config-fixed.yaml -ErrorAction SilentlyContinue

Write-Host "`nConfiguracion completada!" -ForegroundColor Green
Write-Host "- Kubeconfig limpio creado" -ForegroundColor White
Write-Host "- Solo contexto Minikube configurado" -ForegroundColor White
Write-Host "- Sin referencias a GKE" -ForegroundColor White
