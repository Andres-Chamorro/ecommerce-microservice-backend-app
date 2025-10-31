#!/bin/bash
# Script para arreglar la conexión de Jenkins a Minikube

echo "🔧 Arreglando conexión de Jenkins a Minikube..."

# Obtener la IP actual de Minikube
MINIKUBE_IP=$(docker inspect minikube --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "📍 IP de Minikube: $MINIKUBE_IP"

# Copiar certificados de Minikube a Jenkins
echo "📋 Copiando certificados..."
docker exec minikube sh -c "mkdir -p /tmp/certs && cp -r /var/lib/minikube/certs/* /tmp/certs/"
docker cp minikube:/tmp/certs jenkins:/var/jenkins_home/.minikube/

# Crear kubeconfig en Jenkins
echo "⚙️  Creando kubeconfig..."
docker exec jenkins bash -c "mkdir -p /var/jenkins_home/.kube

cat > /var/jenkins_home/.kube/config << 'EOF'
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/jenkins_home/.minikube/certs/ca.crt
    server: https://$MINIKUBE_IP:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
users:
- name: minikube
  user:
    client-certificate: /var/jenkins_home/.minikube/certs/client.crt
    client-key: /var/jenkins_home/.minikube/certs/client.key
EOF

chmod 600 /var/jenkins_home/.kube/config
"

# Verificar conexión
echo "✅ Verificando conexión..."
docker exec jenkins kubectl cluster-info

echo "✅ Conexión a Minikube restaurada"
