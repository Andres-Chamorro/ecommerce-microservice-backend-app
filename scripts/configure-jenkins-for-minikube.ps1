Write-Host "Configurando Jenkins para usar Minikube..." -ForegroundColor Cyan

# Obtener IP de Minikube
$minikubeIP = minikube ip
Write-Host "IP de Minikube: $minikubeIP" -ForegroundColor Yellow

# Copiar kubeconfig de Minikube a Jenkins
Write-Host "Copiando kubeconfig de Minikube a Jenkins..." -ForegroundColor Yellow
$kubeconfig = "$env:USERPROFILE\.kube\config"

docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp $kubeconfig jenkins:/var/jenkins_home/.kube/config

Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "Jenkins ahora puede acceder a Minikube en $minikubeIP" -ForegroundColor Cyan
