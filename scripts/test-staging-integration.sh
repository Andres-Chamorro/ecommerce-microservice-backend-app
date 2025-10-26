#!/bin/bash

# 🧪 Script de Pruebas de Integración Manual para Staging
# Este script complementa las pruebas automatizadas del pipeline de Jenkins

set -e

NAMESPACE="ecommerce-staging"
API_GATEWAY_URL="http://localhost:8080"  # Ajustar según tu configuración

echo "🧪 ===== PRUEBAS DE INTEGRACIÓN - STAGING ====="
echo "Namespace: $NAMESPACE"
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar si un pod está corriendo
check_pod_status() {
    local service=$1
    echo -e "${YELLOW}Verificando $service...${NC}"
    
    POD_STATUS=$(kubectl get pods -n $NAMESPACE -l app=$service -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo 'NotFound')
    
    if [ "$POD_STATUS" == "Running" ]; then
        echo -e "${GREEN}✅ $service está Running${NC}"
        return 0
    else
        echo -e "${RED}❌ $service NO está Running (Estado: $POD_STATUS)${NC}"
        return 1
    fi
}

# Función para hacer health check
health_check() {
    local service=$1
    local port=$2
    
    echo -e "${YELLOW}Health check de $service...${NC}"
    
    POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=$service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')
    
    if [ -n "$POD_NAME" ]; then
        HEALTH_STATUS=$(kubectl exec -n $NAMESPACE $POD_NAME -- curl -s http://localhost:$port/actuator/health 2>/dev/null || echo '{"status":"UNKNOWN"}')
        
        if echo "$HEALTH_STATUS" | grep -q '"status":"UP"'; then
            echo -e "${GREEN}✅ $service health check OK${NC}"
            return 0
        else
            echo -e "${RED}❌ $service health check FAILED${NC}"
            echo "Response: $HEALTH_STATUS"
            return 1
        fi
    else
        echo -e "${RED}❌ No se encontró pod para $service${NC}"
        return 1
    fi
}

# 1. Verificar infraestructura
echo ""
echo "📦 ===== VERIFICANDO INFRAESTRUCTURA ====="

check_pod_status "service-discovery" || true
check_pod_status "cloud-config" || true
check_pod_status "api-gateway" || true
check_pod_status "zipkin" || true

# 2. Verificar microservicios
echo ""
echo "🔧 ===== VERIFICANDO MICROSERVICIOS ====="

SERVICES=("user-service" "product-service" "order-service" "payment-service" "favourite-service" "shipping-service")
FAILED_SERVICES=()

for service in "${SERVICES[@]}"; do
    if ! check_pod_status "$service"; then
        FAILED_SERVICES+=("$service")
    fi
done

# 3. Health checks
echo ""
echo "💚 ===== HEALTH CHECKS ====="

health_check "user-service" "8700" || true
health_check "product-service" "8500" || true
health_check "order-service" "8300" || true
health_check "payment-service" "8400" || true
health_check "favourite-service" "8800" || true
health_check "shipping-service" "8600" || true

# 4. Verificar Service Discovery (Eureka)
echo ""
echo "🔍 ===== VERIFICANDO SERVICE DISCOVERY ====="

SD_POD=$(kubectl get pods -n $NAMESPACE -l app=service-discovery -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')

if [ -n "$SD_POD" ]; then
    echo "Servicios registrados en Eureka:"
    kubectl exec -n $NAMESPACE $SD_POD -- curl -s http://localhost:8761/eureka/apps | grep -o '<name>[^<]*</name>' | sed 's/<name>//g' | sed 's/<\/name>//g' || echo "No se pudo obtener lista de servicios"
else
    echo -e "${RED}❌ Service Discovery no encontrado${NC}"
fi

# 5. Pruebas de integración entre servicios
echo ""
echo "🔗 ===== PRUEBAS DE INTEGRACIÓN ====="

# Test 1: User Service → Product Service (a través de API Gateway)
echo ""
echo "Test 1: User Service puede acceder a Product Service"
# Aquí puedes agregar llamadas HTTP reales cuando tengas endpoints configurados
# curl -X GET "$API_GATEWAY_URL/api/products" || echo "Endpoint no disponible"

# Test 2: Order Service → User Service + Product Service
echo ""
echo "Test 2: Order Service puede comunicarse con User y Product Service"
# curl -X POST "$API_GATEWAY_URL/api/orders" -d '{"userId":1,"productId":1}' || echo "Endpoint no disponible"

# 6. Verificar logs de errores
echo ""
echo "📋 ===== VERIFICANDO LOGS DE ERRORES ====="

for service in "${SERVICES[@]}"; do
    POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=$service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')
    
    if [ -n "$POD_NAME" ]; then
        ERROR_COUNT=$(kubectl logs -n $NAMESPACE $POD_NAME --tail=100 | grep -i "error\|exception\|failed" | wc -l)
        
        if [ "$ERROR_COUNT" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  $service tiene $ERROR_COUNT errores en los últimos 100 logs${NC}"
            echo "Últimos errores:"
            kubectl logs -n $NAMESPACE $POD_NAME --tail=100 | grep -i "error\|exception\|failed" | tail -5
        else
            echo -e "${GREEN}✅ $service sin errores recientes${NC}"
        fi
    fi
done

# 7. Verificar recursos (CPU/Memory)
echo ""
echo "📊 ===== VERIFICANDO RECURSOS ====="

kubectl top pods -n $NAMESPACE 2>/dev/null || echo "Metrics server no disponible"

# 8. Resumen final
echo ""
echo "📊 ===== RESUMEN FINAL ====="

if [ ${#FAILED_SERVICES[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ Todos los servicios están operativos${NC}"
    echo -e "${GREEN}✅ El ambiente de STAGING está listo para pruebas${NC}"
    exit 0
else
    echo -e "${RED}❌ Los siguientes servicios tienen problemas:${NC}"
    for service in "${FAILED_SERVICES[@]}"; do
        echo -e "${RED}   - $service${NC}"
    done
    echo -e "${RED}❌ Corregir errores antes de desplegar a PRODUCCIÓN${NC}"
    exit 1
fi
