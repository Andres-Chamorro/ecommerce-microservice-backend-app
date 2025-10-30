# Script para verificar la configuracion de Jenkins con Minikube

Write-Host "`n=== Verificacion de Jenkins + Minikube ===" -ForegroundColor Cyan

# 1. Verificar que los contenedores esten corriendo
Write-Host "`n1. Estado de contenedores:" -ForegroundColor Yellow
docker ps --filter "name=jenkins" --filter "name=minikube" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Verificar IP de Minikube
Write-Host "`n2. IP de Minikube:" -ForegroundColor Yellow
$minikubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minikube
Write-Host "   $minikubeIP" -ForegroundColor Green

# 3. Verificar kubeconfig en Jenkins
Write-Host "`n3. Kubeconfig en Jenkins:" -ForegroundColor Yellow
docker exec -u jenkins jenkins sh -c "kubectl config current-context"

# 4. Verificar conexion a Minikube
Write-Host "`n4. Conexion a Minikube:" -ForegroundColor Yellow
docker exec -u jenkins jenkins kubectl get nodes

# 5. Verificar namespaces
Write-Host "`n5. Namespaces disponibles:" -ForegroundColor Yellow
docker exec -u jenkins jenkins kubectl get namespaces

# 6. Verificar certificados
Write-Host "`n6. Certificados de Minikube:" -ForegroundColor Yellow
docker exec jenkins sh -c "ls -la /var/jenkins_home/.minikube/certs/"

Write-Host "`n=== Verificacion completada ===" -ForegroundColor Green
Write-Host "Si todos los pasos anteriores funcionaron, Jenkins esta listo para desplegar en Minikube" -ForegroundColor White
