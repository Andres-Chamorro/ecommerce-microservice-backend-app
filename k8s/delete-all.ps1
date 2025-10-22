# Script de eliminación para Windows PowerShell

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Eliminando E-Commerce Microservices" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Write-Host "Eliminando todos los recursos..." -ForegroundColor Yellow

# Eliminar todos los deployments y services
kubectl delete -f microservices/user-service-deployment.yaml
kubectl delete -f microservices/product-service-deployment.yaml
kubectl delete -f microservices/order-service-deployment.yaml
kubectl delete -f microservices/payment-service-deployment.yaml
kubectl delete -f microservices/favourite-service-deployment.yaml
kubectl delete -f microservices/shipping-service-deployment.yaml
kubectl delete -f infrastructure/api-gateway-deployment.yaml
kubectl delete -f infrastructure/service-discovery-deployment.yaml
kubectl delete -f infrastructure/cloud-config-deployment.yaml
kubectl delete -f infrastructure/zipkin-deployment.yaml

# Opcional: Eliminar el namespace
$response = Read-Host "¿Deseas eliminar el namespace completo? (y/n)"
if ($response -eq 'y' -or $response -eq 'Y') {
    kubectl delete namespace ecommerce-dev
    Write-Host "Namespace eliminado" -ForegroundColor Red
} else {
    Write-Host "Namespace conservado" -ForegroundColor Yellow
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Limpieza completada" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
