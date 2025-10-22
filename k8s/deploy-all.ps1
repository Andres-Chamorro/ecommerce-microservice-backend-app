# Script de despliegue para Windows PowerShell

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Desplegando E-Commerce Microservices" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Crear namespace
Write-Host "[1/4] Creando namespace..." -ForegroundColor Yellow
kubectl apply -f base/namespace.yaml

# Esperar un momento
Start-Sleep -Seconds 2

# Desplegar servicios de infraestructura primero
Write-Host "[2/4] Desplegando servicios de infraestructura..." -ForegroundColor Yellow
kubectl apply -f infrastructure/zipkin-deployment.yaml
kubectl apply -f infrastructure/service-discovery-deployment.yaml
kubectl apply -f infrastructure/cloud-config-deployment.yaml

# Esperar a que los servicios de infraestructura estén listos
Write-Host "Esperando a que los servicios de infraestructura estén listos..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=zipkin -n ecommerce-dev --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce-dev --timeout=120s
kubectl wait --for=condition=ready pod -l app=cloud-config -n ecommerce-dev --timeout=120s

# Desplegar API Gateway
Write-Host "[3/4] Desplegando API Gateway..." -ForegroundColor Yellow
kubectl apply -f infrastructure/api-gateway-deployment.yaml

# Esperar a que API Gateway esté listo
kubectl wait --for=condition=ready pod -l app=api-gateway -n ecommerce-dev --timeout=120s

# Desplegar microservicios de negocio
Write-Host "[4/4] Desplegando microservicios de negocio..." -ForegroundColor Yellow
kubectl apply -f microservices/user-service-deployment.yaml
kubectl apply -f microservices/product-service-deployment.yaml
kubectl apply -f microservices/order-service-deployment.yaml
kubectl apply -f microservices/payment-service-deployment.yaml
kubectl apply -f microservices/favourite-service-deployment.yaml
kubectl apply -f microservices/shipping-service-deployment.yaml

# Mostrar estado de los pods
Write-Host "======================================" -ForegroundColor Green
Write-Host "Despliegue completado" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Estado de los pods:" -ForegroundColor Cyan
kubectl get pods -n ecommerce-dev

Write-Host ""
Write-Host "Estado de los servicios:" -ForegroundColor Cyan
kubectl get svc -n ecommerce-dev

Write-Host ""
Write-Host "Para acceder al API Gateway:" -ForegroundColor Green
Write-Host "kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev"
Write-Host ""
Write-Host "Para acceder a Eureka:" -ForegroundColor Green
Write-Host "kubectl port-forward svc/service-discovery 8761:8761 -n ecommerce-dev"
Write-Host ""
Write-Host "Para acceder a Zipkin:" -ForegroundColor Green
Write-Host "kubectl port-forward svc/zipkin 9411:9411 -n ecommerce-dev"
