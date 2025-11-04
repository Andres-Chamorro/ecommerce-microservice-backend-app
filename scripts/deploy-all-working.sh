#!/bin/bash

# Script que realmente funciona para desplegar en Minikube

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
    echo "  Construyendo imagen..."
    docker build -t docker.io/library/${SERVICE}:dev-manual -f $SERVICE/Dockerfile . > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo "  ✗ Error construyendo imagen"
        continue
    fi
    echo "  ✓ Imagen construida"
    
    # Cargar en Minikube con el nombre completo
    echo "  Cargando en Minikube..."
    docker save docker.io/library/${SERVICE}:dev-manual | docker exec -i minikube ctr -n k8s.io images import - > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo "  ✗ Error cargando imagen"
        continue
    fi
    echo "  ✓ Imagen cargada"
    
    # Verificar que la imagen está en Minikube
    echo "  Verificando imagen en Minikube..."
    docker exec minikube ctr -n k8s.io images ls | grep "${SERVICE}:dev-manual" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Imagen verificada"
    else
        echo "  ✗ Imagen NO encontrada en Minikube"
        continue
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
        image: docker.io/library/${SERVICE}:dev-manual
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
        echo "  ✓ Desplegado en Kubernetes"
    else
        echo "  ✗ Error desplegando en Kubernetes"
    fi
    echo ""
done

echo "Esperando 60 segundos a que los pods arranquen..."
sleep 60

echo ""
echo "Estado de los pods:"
kubectl get pods -n $NAMESPACE

echo ""
echo "Servicios:"
kubectl get svc -n $NAMESPACE

echo ""
echo "✓ Completado"
