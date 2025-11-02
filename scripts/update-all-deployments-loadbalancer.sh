#!/bin/bash

# Script para actualizar todos los deployments a LoadBalancer

echo "🔧 Actualizando deployments a LoadBalancer..."

services=("product-service" "order-service" "payment-service" "favourite-service")

for service in "${services[@]}"; do
    deployment="k8s/microservices/${service}-deployment.yaml"
    
    if [ -f "$deployment" ]; then
        echo "📝 Actualizando $deployment..."
        sed -i 's/type: ClusterIP/type: LoadBalancer  # IP externa para pruebas E2E/g' "$deployment"
        echo "✅ $deployment actualizado"
    else
        echo "⚠️ $deployment no encontrado"
    fi
done

echo ""
echo "✅ Todos los deployments actualizados a LoadBalancer"
