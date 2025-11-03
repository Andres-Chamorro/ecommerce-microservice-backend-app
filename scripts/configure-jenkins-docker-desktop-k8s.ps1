Write-Host "Configurando Jenkins para acceder a Docker Desktop Kubernetes..." -ForegroundColor Cyan

# Obtener la IP del host desde Docker Desktop
$hostIP = "host.docker.internal"

Write-Host "Copiando kubeconfig de Docker Desktop a Jenkins..." -ForegroundColor Yellow

# Copiar el kubeconfig de Docker Desktop al volumen de Jenkins
$kubeconfig = "$env:USERPROFILE\.kube\config"
$jenkinsKubeconfig = "jenkins-data\.kube\config"

# Crear directorio si no existe
docker exec jenkins mkdir -p /var/jenkins_home/.kube

# Copiar el archivo
docker cp $kubeconfig jenkins:/var/jenkins_home/.kube/config

# Actualizar el server URL para usar host.docker.internal
docker exec jenkins sh -c "sed -i 's|https://kubernetes.docker.internal:6443|https://host.docker.internal:6443|g' /var/jenkins_home/.kube/config"

Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "Jenkins ahora puede acceder a Docker Desktop Kubernetes usando host.docker.internal" -ForegroundColor Cyan
