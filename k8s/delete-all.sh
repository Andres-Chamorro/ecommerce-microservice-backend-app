#!/bin/bash

echo "======================================"
echo "Eliminando E-Commerce Microservices"
echo "======================================"

# Colores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Eliminando todos los recursos...${NC}"

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

# Opcional: Eliminar el namespace (esto eliminará todo)
echo -e "${RED}¿Deseas eliminar el namespace completo? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    kubectl delete namespace ecommerce-dev
    echo -e "${RED}Namespace eliminado${NC}"
else
    echo "Namespace conservado"
fi

echo -e "${YELLOW}======================================"
echo "Limpieza completada"
echo "======================================${NC}"
