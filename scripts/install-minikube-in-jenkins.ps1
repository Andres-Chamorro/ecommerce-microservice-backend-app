# Script para instalar minikube CLI en el contenedor Jenkins

Write-Host "Instalando minikube CLI en Jenkins..." -ForegroundColor Cyan

# Descargar e instalar minikube en Jenkins
docker exec -u root jenkins sh -c @"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
install minikube-linux-amd64 /usr/local/bin/minikube && \
rm minikube-linux-amd64 && \
minikube version
"@

Write-Host "`nVerificando instalacion..." -ForegroundColor Yellow
docker exec jenkins minikube version

Write-Host "`nConfigurar minikube para usar el perfil existente..." -ForegroundColor Yellow
docker exec jenkins sh -c "minikube config set profile minikube"

Write-Host "`nminikube instalado correctamente en Jenkins!" -ForegroundColor Green
