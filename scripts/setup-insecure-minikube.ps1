# Configurar Minikube sin TLS para Jenkins
Write-Host "=== Configurando Minikube sin TLS ===" -ForegroundColor Green

# Obtener IP de Minikube
$minikubeIP = "192.168.67.2"
Write-Host "`nMinikube IP: $minikubeIP" -ForegroundColor Cyan

# Paso 1: Habilitar puerto inseguro 8080 en API server
Write-Host "`n1. Habilitando puerto inseguro 8080..." -ForegroundColor Yellow
docker exec minikube sh -c "sed -i '/- kube-apiserver/a\    - --insecure-port=8080' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null || true"
docker exec minikube sh -c "sed -i '/- kube-apiserver/a\    - --insecure-bind-address=0.0.0.0' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null || true"

Write-Host "Esperando 20 segundos para que API server se reinicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Paso 2: Verificar puerto 8080
Write-Host "`n2. Verificando puerto 8080..." -ForegroundColor Yellow
docker exec minikube curl -s http://localhost:8080/healthz

# Paso 3: Crear kubeconfig inseguro
Write-Host "`n3. Creando kubeconfig inseguro..." -ForegroundColor Yellow

@"
apiVersion: v1
clusters:
- cluster:
    server: http://${minikubeIP}:8080
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user: {}
"@ | Out-File -FilePath "kubeconfig-insecure.yaml" -Encoding UTF8

# Paso 4: Copiar a Jenkins
Write-Host "`n4. Copiando kubeconfig a Jenkins..." -ForegroundColor Yellow
docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp kubeconfig-insecure.yaml jenkins:/var/jenkins_home/.kube/config
Remove-Item kubeconfig-insecure.yaml

# Paso 5: Probar kubectl desde Jenkins
Write-Host "`n5. Probando kubectl desde Jenkins..." -ForegroundColor Yellow
docker exec jenkins kubectl get nodes

Write-Host "`n=== Configuración Completada ===" -ForegroundColor Green
Write-Host "Kubernetes API: http://${minikubeIP}:8080" -ForegroundColor Cyan
Write-Host "Docker Daemon: tcp://${minikubeIP}:2376" -ForegroundColor Cyan
