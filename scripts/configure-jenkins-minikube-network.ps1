# Script para configurar la red entre Jenkins y Minikube
Write-Host "Configurando red entre Jenkins y Minikube..." -ForegroundColor Green

# Obtener la IP del contenedor de Minikube en la red de Docker
$minikubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minikube
Write-Host "IP de Minikube en red Docker: $minikubeIP" -ForegroundColor Yellow

# Obtener el puerto de la API de Kubernetes
$apiPort = docker inspect minikube --format='{{(index (index .NetworkSettings.Ports "8443/tcp") 0).HostPort}}'
if ([string]::IsNullOrEmpty($apiPort)) {
    $apiPort = "8443"
}
Write-Host "Puerto API de Kubernetes: $apiPort" -ForegroundColor Yellow

# Crear kubeconfig personalizado para Jenkins
$kubeconfig = @"
apiVersion: v1
kind: Config
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
users:
- name: minikube
  user:
    client-certificate-data: $(docker exec minikube cat /var/lib/minikube/certs/apiserver.crt | base64 -w 0)
    client-key-data: $(docker exec minikube cat /var/lib/minikube/certs/apiserver.key | base64 -w 0)
"@

# Guardar en archivo temporal
$tempFile = "jenkins-minikube-config.yaml"
$kubeconfig | Out-File -FilePath $tempFile -Encoding UTF8

# Copiar al contenedor de Jenkins
Write-Host "Copiando kubeconfig a Jenkins..." -ForegroundColor Yellow
docker cp $tempFile jenkins:/var/jenkins_home/.kube/config

# Dar permisos correctos
docker exec jenkins chmod 600 /var/jenkins_home/.kube/config
docker exec jenkins chown jenkins:jenkins /var/jenkins_home/.kube/config

# Limpiar archivo temporal
Remove-Item $tempFile

Write-Host "`nKubeconfig configurado exitosamente!" -ForegroundColor Green
Write-Host "Verificando conexión desde Jenkins..." -ForegroundColor Yellow

# Verificar que Jenkins puede conectarse
docker exec jenkins kubectl cluster-info
docker exec jenkins kubectl get nodes

Write-Host "`nJenkins puede conectarse a Minikube exitosamente!" -ForegroundColor Green
