#!/bin/bash

# Script corregido para desplegar todos los servicios en Minikube

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
    
    if [ $? -ne 0 ]; then
        echo "  ✗ Error construyendo imagen"
        continue
    fi
    
    # Cargar en Minikube usando minikube image load
    echo "  Cargando en Minikube..."
    minikube image load ${SERVICE}:dev-manual > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo "  ✗ Error cargando imagen"
        continue
    fi
    
    # Verificar que la imagen está en Minikube
    echo "  Verificando imagen..."
    minikube ssh "docker images | grep ${SERVICE}" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Imagen verificada en Minikube"
    else
        echo "  ⚠ Imagen no encontrada, pero continuando..."
    fi
    
    # Crear YAML y desplegar
    echo "  Desplegando en Kubernetes..."
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
        imagePullPolicy: IfNotPresent
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

echo "Esperando 45 segundos a que los pods arranquen..."
sleep 45

echo ""
echo "Estado de los pods:"
kubectl get pods -n $NAMESPACE

echo ""
echo "Verificando pods que no están Running:"
NOT_RUNNING=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)

if [ $NOT_RUNNING -gt 0 ]; then
    echo ""
    echo "⚠ Hay $NOT_RUNNING pods que no están Running"
    echo "Detalles:"
    kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running
    echo ""
    echo "Para ver logs de un pod con problemas:"
    echo "  kubectl logs -n $NAMESPACE <pod-name>"
    echo "  kubectl describe pod -n $NAMESPACE <pod-name>"
else
    echo ""
    echo "✓ Todos los pods están Running"
fi

echo ""
echo "✓ Completado - Ahora puedes ejecutar pipelines con pruebas de integración"
