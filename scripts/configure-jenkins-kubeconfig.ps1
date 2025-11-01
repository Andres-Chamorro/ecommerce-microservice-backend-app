Write-Host "Configurando kubeconfig en Jenkins..." -ForegroundColor Cyan

Write-Host "`n1. Copiando kubeconfig de Minikube a Jenkins..." -ForegroundColor Yellow
docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

Write-Host "`n2. Ajustando permisos..." -ForegroundColor Yellow
docker exec jenkins chown -R jenkins:jenkins /var/jenkins_home/.kube
docker exec jenkins chmod 600 /var/jenkins_home/.kube/config

Write-Host "`n3. Verificando configuracion..." -ForegroundColor Yellow
docker exec jenkins kubectl config view

Write-Host "`n4. Probando conexion a Minikube..." -ForegroundColor Yellow
docker exec jenkins kubectl config use-context minikube
docker exec jenkins kubectl cluster-info

Write-Host "`nkubeconfig configurado correctamente en Jenkins" -ForegroundColor Green
