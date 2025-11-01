# Script para configurar Minikube para exponer el puerto 2376 sin TLS
# Fecha: 2025-10-31

Write-Host "Configurando Minikube para exponer puerto 2376 sin TLS..." -ForegroundColor Cyan

# Verificar que Minikube esté corriendo
Write-Host "`nVerificando estado de Minikube..." -ForegroundColor Yellow
minikube status

# Obtener la IP de Minikube
Write-Host "`nObteniendo IP de Minikube..." -ForegroundColor Yellow
$minikubeIP = minikube ip
Write-Host "IP de Minikube: $minikubeIP" -ForegroundColor Green

# Verificar puertos expuestos
Write-Host "`nVerificando puertos expuestos en el contenedor de Minikube..." -ForegroundColor Yellow
docker ps --filter "name=minikube" --format "table {{.Names}}\t{{.Ports}}"

Write-Host "`nOpciones para exponer el puerto 2376:" -ForegroundColor Cyan
Write-Host "1. Usar 'minikube docker-env' para que Jenkins use el mismo Docker daemon" -ForegroundColor White
Write-Host "2. Configurar kubectl para usar el API server de Minikube directamente" -ForegroundColor White

Write-Host "`nPara verificar la conexion desde Jenkins, ejecuta:" -ForegroundColor Magenta
Write-Host "  docker exec jenkins curl -k http://192.168.67.2:2376" -ForegroundColor White

Write-Host "`nSi el puerto 2376 no esta disponible, puedes:" -ForegroundColor Yellow
Write-Host "1. Usar el puerto 8443 (API server de Kubernetes) que ya esta expuesto" -ForegroundColor White
Write-Host "2. Configurar un proxy o port-forward" -ForegroundColor White
