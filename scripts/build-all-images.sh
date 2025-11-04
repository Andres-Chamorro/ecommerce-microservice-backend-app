#!/bin/bash

echo "======================================"
echo "Construyendo Imágenes Docker"
echo "======================================"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compilar todos los servicios
echo -e "${YELLOW}[1/2] Compilando servicios con Maven...${NC}"
./mvnw clean package -DskipTests

# Construir imágenes Docker
echo -e "${YELLOW}[2/2] Construyendo imágenes Docker...${NC}"

echo "Building user-service..."
docker build -t ecommerce-user-service:latest -f user-service/Dockerfile .

echo "Building product-service..."
docker build -t ecommerce-product-service:latest -f product-service/Dockerfile .

echo "Building order-service..."
docker build -t ecommerce-order-service:latest -f order-service/Dockerfile .

echo "Building payment-service..."
docker build -t ecommerce-payment-service:latest -f payment-service/Dockerfile .

echo "Building favourite-service..."
docker build -t ecommerce-favourite-service:latest -f favourite-service/Dockerfile .

echo "Building shipping-service..."
docker build -t ecommerce-shipping-service:latest -f shipping-service/Dockerfile .

echo -e "${GREEN}======================================"
echo "Todas las imágenes construidas"
echo "======================================${NC}"

# Mostrar imágenes
echo ""
echo "Imágenes disponibles:"
docker images | grep ecommerce
