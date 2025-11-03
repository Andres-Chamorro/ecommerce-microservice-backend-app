# Script para arreglar la conexión de Jenkins a Minikube

Write-Host "🔧 Arreglando conexión de Jenkins a Minikube..." -ForegroundColor Cyan

# Obtener la IP actual de Minikube
$minikubeIP = docker inspect minikube --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
Write-Host "📍 IP de Minikube: $minikubeIP" -ForegroundColor Yellow

# Copiar certificados de Minikube a Jenkins
Write-Host "📋 Copiando certificados..." -ForegroundColor Yellow
docker exec minikube sh -c "mkdir -p /tmp/certs && cp -r /var/lib/minikube/certs/* /tmp/certs/"
docker cp minikube:/tmp/certs jenkins:/var/jenkins_home/.minikube/certs/

# Crear kubeconfig en Jenkins
Write-Host "⚙️  Creando kubeconfig..." -ForegroundColor Yellow
docker exec jenkins bash -c @"
mkdir -p /var/jenkins_home/.kube

cat > /var/jenkins_home/.kube/config << 'EOF'
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/jenkins_home/.minikube/certs/ca.crt
    server: https://$minikubeIP:8443
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
"@

# Verificar conexión
Write-Host "✅ Verificando conexión..." -ForegroundColor Yellow
docker exec jenkins kubectl cluster-info

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Conexión a Minikube restaurada correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al conectar a Minikube" -ForegroundColor Red
    Write-Host "Verifica que Minikube esté corriendo: docker ps | grep minikube" -ForegroundColor Yellow
}
