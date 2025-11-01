# Script para configurar acceso de Jenkins a Minikube

Write-Host "Configurando acceso de Jenkins a Minikube..." -ForegroundColor Green

# 1. Instalar minikube en Jenkins
Write-Host "`n1. Instalando minikube en el contenedor de Jenkins..."
docker exec -u root jenkins bash -c "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64"

# 2. Verificar instalación
Write-Host "`n2. Verificando instalación..."
docker exec jenkins minikube version

# 3. Copiar configuración de minikube
Write-Host "`n3. Copiando configuración de Minikube..."
$minikubePath = "$env:USERPROFILE\.minikube"
docker exec -u root jenkins bash -c "mkdir -p /var/jenkins_home/.minikube"
docker cp "$minikubePath\profiles" jenkins:/var/jenkins_home/.minikube/
docker cp "$minikubePath\ca.crt" jenkins:/var/jenkins_home/.minikube/
docker cp "$minikubePath\client.crt" jenkins:/var/jenkins_home/.minikube/
docker cp "$minikubePath\client.key" jenkins:/var/jenkins_home/.minikube/

# 4. Ajustar permisos
Write-Host "`n4. Ajustando permisos..."
docker exec -u root jenkins chown -R jenkins:jenkins /var/jenkins_home/.minikube

Write-Host "`nConfiguracion completada!" -ForegroundColor Green
Write-Host "Ahora Jenkins puede usar minikube image load en los pipelines."
