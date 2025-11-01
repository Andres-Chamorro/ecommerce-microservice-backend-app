Write-Host "Configurando acceso de Jenkins a Minikube..." -ForegroundColor Cyan

# Obtener IP de Minikube
$minikubeIP = minikube ip
Write-Host "IP de Minikube: $minikubeIP" -ForegroundColor Yellow

# Leer certificados y convertir a base64
$caCert = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.minikube\ca.crt"))
$clientCert = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.minikube\profiles\minikube\client.crt"))
$clientKey = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.minikube\profiles\minikube\client.key"))

# Crear kubeconfig usando la IP de Minikube y puerto 8443 (API server)
$kubeconfigContent = @"
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

# Guardar temporalmente
$kubeconfigContent | Out-File -FilePath "jenkins-kubeconfig.tmp" -Encoding UTF8 -NoNewline

Write-Host "`nCopiando kubeconfig a Jenkins..." -ForegroundColor Yellow
docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp jenkins-kubeconfig.tmp jenkins:/var/jenkins_home/.kube/config
docker exec jenkins chown -R jenkins:jenkins /var/jenkins_home/.kube
docker exec jenkins chmod 600 /var/jenkins_home/.kube/config

Remove-Item jenkins-kubeconfig.tmp

Write-Host "`nProbando conexion..." -ForegroundColor Yellow
docker exec jenkins kubectl cluster-info

Write-Host "`nConfiguracion completada" -ForegroundColor Green
