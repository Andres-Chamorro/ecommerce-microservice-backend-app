#!/bin/bash

# Script para limpiar y desplegar todos los servicios desde cero

NAMESPACE="ecommerce-dev"

echo "========================================"
echo "Limpieza y Despliegue de Servicios"
echo "========================================"
echo ""

# 1. Eliminar namespace completo (esto elimina todo)
echo "1. Eliminando namespace anterior..."
kubectl delete namespace $NAMESPACE 2>/dev/null || true
echo "   Esperando a que se elimine completamente..."
sleep 10

# 2. Crear namespace limpio
echo "2. Creando namespace limpio..."
kubectl create namespace $NAMESPACE

# 3. Servicios y puertos
declare -A SERVICES
SERVICES[user-service]=8700
SERVICES[product-service]=8200
SERVICES[order-service]=8300
SERVICES[payment-service]=8400
SERVICES[favourite-service]=8800
SERVICES[shipping-service]=8600

echo ""
echo "3. Construyendo y desplegando servicios..."
echo ""

# 4. Desplegar cada servicio
for SERVICE in "${!SERVICES[@]}"; do
    PORT=${SERVICES[$SERVICE]}
    
    echo "[$SERVICE]"
    
    # Construir imagen
    echo "  - Construyendo imagen..."
    docker build -t ${SERVICE}:dev-manual -f $SERVICE/Dockerfile . > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo "  ✗ Error construyendo imagen"
        continue
    fi
    
    # Cargar en Minikube
    echo "  - Cargando en Minikube..."
    docker save ${SERVICE}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo "  ✗ Error cargando en Minikube"
        continue
    fi
    
    # Crear YAML y desplegar
    echo "  - Desplegando en Kubernetes..."
    cat <<EOF | kubectl apply -f - > /dev/null 2>&1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $SERVICE
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $SERVICE
  template:
    metadata:
      labels:
        app: $SERVICE
    spec:
      containers:
      - name: $SERVICE
        image: ${SERVICE}:dev-manual
        ports:
        - containerPort: $PORT
        imagePullPolicy: Never
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: dev
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE
  namespace: $NAMESPACE
spec:
  selector:
    app: $SERVICE
  ports:
  - port: $PORT
    targetPort: $PORT
  type: ClusterIP
EOF
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Desplegado correctamente"
    else
        echo "  ✗ Error desplegando"
    fi
    echo ""
done

echo "4. Esperando a que los pods arranquen (60 segundos)..."
sleep 60

echo ""
echo "5. Estado final:"
echo ""
kubectl get pods -n $NAMESPACE
echo ""
kubectl get svc -n $NAMESPACE

echo ""
echo "========================================"
echo "✓ Proceso completado"
echo "========================================"
echo ""
echo "Verifica que todos los pods estén en estado 'Running'"
echo "Si alguno está en 'ContainerCreating', espera un poco más"
echo ""
echo "Para ver logs de un servicio:"
echo "  kubectl logs -n $NAMESPACE -l app=user-service"
echo ""
