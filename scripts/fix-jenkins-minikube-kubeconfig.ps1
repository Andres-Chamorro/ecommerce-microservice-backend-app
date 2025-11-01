# Script para copiar el kubeconfig de Minikube a Jenkins
Write-Host "Copiando kubeconfig de Minikube a Jenkins..." -ForegroundColor Green

# Obtener el kubeconfig de minikube
$minikubeConfig = minikube kubectl -- config view --flatten --minify

# Guardar en archivo temporal
$tempFile = "minikube-config.yaml"
$minikubeConfig | Out-File -FilePath $tempFile -Encoding UTF8

# Copiar al contenedor de Jenkins
docker cp $tempFile jenkins:/var/jenkins_home/.kube/config

# Dar permisos correctos
docker exec jenkins chmod 600 /var/jenkins_home/.kube/config
docker exec jenkins chown jenkins:jenkins /var/jenkins_home/.kube/config

# Limpiar archivo temporal
Remove-Item $tempFile

Write-Host "Kubeconfig copiado exitosamente!" -ForegroundColor Green
Write-Host "Verificando conexión desde Jenkins..." -ForegroundColor Yellow

# Verificar que Jenkins puede conectarse
docker exec jenkins kubectl cluster-info
