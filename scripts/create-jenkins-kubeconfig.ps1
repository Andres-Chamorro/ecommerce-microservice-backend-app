Write-Host "Creando kubeconfig para Jenkins con certificados embebidos..." -ForegroundColor Cyan

# Obtener IP del host para que Jenkins pueda acceder a Minikube
$minikubeIP = docker exec minikube hostname -I | ForEach-Object { $_.Trim() }
Write-Host "IP de Minikube: $minikubeIP" -ForegroundColor Yellow

# Leer certificados
$caCert = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.minikube\ca.crt"))
$clientCert = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.minikube\profiles\minikube\client.crt"))
$clientKey = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.minikube\profiles\minikube\client.key"))

# Crear kubeconfig con certificados embebidos
$kubeconfigContent = @"
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $caCert
    server: https://host.docker.internal:51744
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

Write-Host "Ajustando permisos..." -ForegroundColor Yellow
docker exec jenkins chown -R jenkins:jenkins /var/jenkins_home/.kube
docker exec jenkins chmod 600 /var/jenkins_home/.kube/config

Write-Host "Limpiando archivo temporal..." -ForegroundColor Yellow
Remove-Item jenkins-kubeconfig.tmp

Write-Host "`nVerificando configuracion..." -ForegroundColor Yellow
docker exec jenkins kubectl config view

Write-Host "`nkubeconfig creado y configurado en Jenkins" -ForegroundColor Green
