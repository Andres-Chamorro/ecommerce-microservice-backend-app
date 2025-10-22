#!/bin/bash

echo "======================================"
echo "Desplegando E-Commerce Microservices"
echo "======================================"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Crear namespace
echo -e "${YELLOW}[1/4] Creando namespace...${NC}"
kubectl apply -f base/namespace.yaml

# Esperar un momento
sleep 2

# Desplegar servicios de infraestructura primero
echo -e "${YELLOW}[2/4] Desplegando servicios de infraestructura...${NC}"
kubectl apply -f infrastructure/zipkin-deployment.yaml
kubectl apply -f infrastructure/service-discovery-deployment.yaml
kubectl apply -f infrastructure/cloud-config-deployment.yaml

# Esperar a que los servicios de infraestructura estén listos
echo -e "${YELLOW}Esperando a que los servicios de infraestructura estén listos...${NC}"
kubectl wait --for=condition=ready pod -l app=zipkin -n ecommerce-dev --timeout=120s
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce-dev --timeout=120s
kubectl wait --for=condition=ready pod -l app=cloud-config -n ecommerce-dev --timeout=120s

# Desplegar API Gateway
echo -e "${YELLOW}[3/4] Desplegando API Gateway...${NC}"
kubectl apply -f infrastructure/api-gateway-deployment.yaml

# Esperar a que API Gateway esté listo
kubectl wait --for=condition=ready pod -l app=api-gateway -n ecommerce-dev --timeout=120s

# Desplegar microservicios de negocio
echo -e "${YELLOW}[4/4] Desplegando microservicios de negocio...${NC}"
kubectl apply -f microservices/user-service-deployment.yaml
kubectl apply -f microservices/product-service-deployment.yaml
kubectl apply -f microservices/order-service-deployment.yaml
kubectl apply -f microservices/payment-service-deployment.yaml
kubectl apply -f microservices/favourite-service-deployment.yaml
kubectl apply -f microservices/shipping-service-deployment.yaml

# Mostrar estado de los pods
echo -e "${GREEN}======================================"
echo "Despliegue completado"
echo "======================================${NC}"
echo ""
echo "Estado de los pods:"
kubectl get pods -n ecommerce-dev

echo ""
echo "Estado de los servicios:"
kubectl get svc -n ecommerce-dev

echo ""
echo -e "${GREEN}Para acceder al API Gateway:${NC}"
echo "kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev"
echo ""
echo -e "${GREEN}Para acceder a Eureka:${NC}"
echo "kubectl port-forward svc/service-discovery 8761:8761 -n ecommerce-dev"
echo ""
echo -e "${GREEN}Para acceder a Zipkin:${NC}"
echo "kubectl port-forward svc/zipkin 9411:9411 -n ecommerce-dev"
