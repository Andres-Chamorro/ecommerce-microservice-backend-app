#!/bin/bash

# Script para desplegar todos los servicios en Minikube

NAMESPACE="ecommerce-dev"

echo "========================================"
echo "Desplegando servicios en Minikube"
echo "========================================"
echo ""

# Crear namespace
kubectl create namespace $NAMESPACE 2>/dev/null || true

# Servicios y puertos
declare -A SERVICES
SERVICES[user-service]=8700
SERVICES[product-service]=8200
SERVICES[order-service]=8300
SERVICES[payment-service]=8400
SERVICES[favourite-service]=8800
SERVICES[shipping-service]=8600

# Desplegar cada servicio
for SERVICE in "${!SERVICES[@]}"; do
    PORT=${SERVICES[$SERVICE]}
    
    echo "[$SERVICE]"
    
    # Construir imagen
    echo "  Construyendo..."
    docker build -t ${SERVICE}:dev-manual -f $SERVICE/Dockerfile . > /dev/null 2>&1
    
    # Cargar en Minikube
    echo "  Cargando en Minikube..."
    docker save ${SERVICE}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - > /dev/null 2>&1
    
    # Crear YAML y desplegar
    echo "  Desplegando..."
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
    
    echo "  ✓ Desplegado"
    echo ""
done

echo "Esperando 30 segundos..."
sleep 30

echo ""
echo "Estado de los pods:"
kubectl get pods -n $NAMESPACE

echo ""
echo "✓ Completado - Ahora puedes ejecutar pipelines con pruebas de integración"
