# Script para construir todas las imágenes Docker en Windows

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Construyendo Imágenes Docker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Compilar todos los servicios
Write-Host "[1/2] Compilando servicios con Maven..." -ForegroundColor Yellow
.\mvnw.cmd clean package -DskipTests

# Construir imágenes Docker
Write-Host "[2/2] Construyendo imágenes Docker..." -ForegroundColor Yellow

Write-Host "Building user-service..." -ForegroundColor Cyan
docker build -t ecommerce-user-service:latest -f user-service/Dockerfile .

Write-Host "Building product-service..." -ForegroundColor Cyan
docker build -t ecommerce-product-service:latest -f product-service/Dockerfile .

Write-Host "Building order-service..." -ForegroundColor Cyan
docker build -t ecommerce-order-service:latest -f order-service/Dockerfile .

Write-Host "Building payment-service..." -ForegroundColor Cyan
docker build -t ecommerce-payment-service:latest -f payment-service/Dockerfile .

Write-Host "Building favourite-service..." -ForegroundColor Cyan
docker build -t ecommerce-favourite-service:latest -f favourite-service/Dockerfile .

Write-Host "Building shipping-service..." -ForegroundColor Cyan
docker build -t ecommerce-shipping-service:latest -f shipping-service/Dockerfile .

Write-Host "======================================" -ForegroundColor Green
Write-Host "Todas las imágenes construidas" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Mostrar imágenes
Write-Host ""
Write-Host "Imágenes disponibles:" -ForegroundColor Cyan
docker images | Select-String "ecommerce"
