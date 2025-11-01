# Solución rápida: usar kubectl proxy en Minikube
Write-Host "=== Solución Rápida Jenkins-Minikube ===" -ForegroundColor Green

$minikubeIP = "192.168.67.2"

# Opción 1: Usar kubectl directamente desde el host en Jenkins
Write-Host "`n1. Configurando kubectl para usar desde host..." -ForegroundColor Yellow

# Copiar el kubeconfig del host a Jenkins
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

# Modificar el server URL para usar localhost con el puerto mapeado
docker exec jenkins sh -c "sed -i 's|https://127.0.0.1:[0-9]*|https://host.docker.internal:57038|g' /var/jenkins_home/.kube/config"

Write-Host "`n2. Probando kubectl desde Jenkins..." -ForegroundColor Yellow
docker exec jenkins kubectl get nodes

Write-Host "`n=== Listo ===" -ForegroundColor Green
