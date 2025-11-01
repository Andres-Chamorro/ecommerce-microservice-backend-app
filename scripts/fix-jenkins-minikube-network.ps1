# Script para arreglar la conectividad entre Jenkins y Minikube

Write-Host "Arreglando conectividad Jenkins <-> Minikube..." -ForegroundColor Green

# 1. Obtener la IP interna de minikube en la red Docker
Write-Host "`n1. Obteniendo IP de minikube..."
$minikubeIP = docker inspect minikube --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
Write-Host "IP de minikube: $minikubeIP"

# 2. Actualizar kubeconfig en Jenkins con la IP correcta
Write-Host "`n2. Actualizando kubeconfig en Jenkins..."
docker exec jenkins bash -c "mkdir -p /var/jenkins_home/.kube"
docker cp minikube:/root/.kube/config jenkins:/tmp/kube-config

# Reemplazar la IP en el kubeconfig
docker exec jenkins bash -c "sed 's|https://.*:8443|https://$minikubeIP:8443|g' /tmp/kube-config > /var/jenkins_home/.kube/config"
docker exec -u root jenkins chown jenkins:jenkins /var/jenkins_home/.kube/config

# 3. Copiar certificados de minikube a Jenkins
Write-Host "`n3. Copiando certificados..."
docker exec jenkins mkdir -p /var/jenkins_home/.minikube
docker cp minikube:/root/.minikube/ca.crt jenkins:/var/jenkins_home/.minikube/
docker cp minikube:/root/.minikube/profiles/minikube/client.crt jenkins:/var/jenkins_home/.minikube/
docker cp minikube:/root/.minikube/profiles/minikube/client.key jenkins:/var/jenkins_home/.minikube/
docker exec -u root jenkins chown -R jenkins:jenkins /var/jenkins_home/.minikube

# 4. Actualizar las rutas de certificados en kubeconfig
Write-Host "`n4. Actualizando rutas de certificados..."
docker exec jenkins bash -c @"
sed -i 's|certificate-authority:.*|certificate-authority: /var/jenkins_home/.minikube/ca.crt|g' /var/jenkins_home/.kube/config
sed -i 's|client-certificate:.*|client-certificate: /var/jenkins_home/.minikube/client.crt|g' /var/jenkins_home/.kube/config
sed -i 's|client-key:.*|client-key: /var/jenkins_home/.minikube/client.key|g' /var/jenkins_home/.kube/config
"@

# 5. Verificar configuración
Write-Host "`n5. Verificando configuración..."
docker exec jenkins cat /var/jenkins_home/.kube/config | Select-String "server:"

Write-Host "`n✓ Configuración completada!" -ForegroundColor Green
Write-Host "Jenkins ahora puede conectarse a minikube en https://$minikubeIP:8443" -ForegroundColor Cyan
