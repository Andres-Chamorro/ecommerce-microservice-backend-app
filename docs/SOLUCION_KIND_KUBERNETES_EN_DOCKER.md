# Solución: Kubernetes en Docker con Kind

## ¿Qué es Kind?

**Kind** (Kubernetes in Docker) es una herramienta que corre clusters de Kubernetes **dentro de contenedores Docker**. Es perfecto para tu caso porque:

✅ No necesitas instalar Minikube
✅ Todo corre en Docker (que ya tienes)
✅ Más ligero y rápido
✅ Perfecto para CI/CD con Jenkins
✅ Jenkins y Kubernetes comparten la misma red Docker

## Instalación de Kind

### Opción 1: Chocolatey (Recomendado)
```powershell
choco install kind
```

### Opción 2: Descarga Manual
```powershell
# Descargar Kind
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe C:\Windows\System32\kind.exe
```

### Opción 3: Go (si tienes Go instalado)
```powershell
go install sigs.k8s.io/kind@v0.20.0
```

## Configuración Rápida

### 1. Instalar Kind
```powershell
choco install kind
```

### 2. Crear Cluster de Kubernetes
```powershell
# Crear cluster llamado "jenkins-dev"
kind create cluster --name jenkins-dev

# Verificar que está corriendo
kind get clusters
kubectl cluster-info --context kind-jenkins-dev
```

### 3. Verificar Contenedores
```powershell
# Deberías ver un contenedor llamado "jenkins-dev-control-plane"
docker ps
```

### 4. Configurar Jenkins

```powershell
# Copiar kubeconfig a Jenkins
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

# Dar permisos
docker exec jenkins chmod 644 /var/jenkins_home/.kube/config

# Verificar que Jenkins puede acceder
docker exec jenkins kubectl get nodes
```

## Ventajas de Kind vs Minikube

| Característica | Kind | Minikube |
|----------------|------|----------|
| Instalación | Más simple | Más compleja |
| Recursos | Más ligero | Más pesado |
| Velocidad | Más rápido | Más lento |
| Integración Docker | Nativa | Requiere configuración |
| Para CI/CD | Excelente | Bueno |
| Para desarrollo local | Bueno | Excelente |

## Cómo Funciona con Jenkins

```
┌─────────────────────────────────────────────────────┐
│                    Docker Host                      │
│                                                     │
│  ┌──────────────┐         ┌──────────────────┐    │
│  │   Jenkins    │────────▶│  Kind Cluster    │    │
│  │  Container   │         │  (K8s Container) │    │
│  │              │         │                  │    │
│  │  - Construye │         │  - Corre Pods    │    │
│  │    imágenes  │         │  - Deployments   │    │
│  │  - Ejecuta   │         │  - Services      │    │
│  │    kubectl   │         │                  │    │
│  └──────────────┘         └──────────────────┘    │
│         │                          │               │
│         └──────────┬───────────────┘               │
│                    │                               │
│              Docker Network                        │
│         (Comparten la misma red)                   │
└─────────────────────────────────────────────────────┘
```

## Cargar Imágenes en Kind

Kind tiene un comando específico para cargar imágenes:

```powershell
# Construir imagen
docker build -t order-service:dev .

# Cargar en Kind
kind load docker-image order-service:dev --name jenkins-dev
```

## Actualizar Jenkinsfiles para Kind

El Jenkinsfile sería casi idéntico, solo cambia cómo cargas la imagen:

```groovy
stage('Build Docker Image') {
    steps {
        script {
            sh """
                cd order-service
                docker build -t order-service:dev-${BUILD_TAG} .
                
                # Cargar imagen en Kind
                kind load docker-image order-service:dev-${BUILD_TAG} --name jenkins-dev
            """
        }
    }
}

stage('Deploy to Kubernetes') {
    steps {
        script {
            sh """
                kubectl apply -f order-service/k8s/
                kubectl rollout status deployment/order-service -n ecommerce-dev
            """
        }
    }
}
```

## Comandos Útiles de Kind

```powershell
# Crear cluster
kind create cluster --name jenkins-dev

# Listar clusters
kind get clusters

# Ver nodos
kind get nodes --name jenkins-dev

# Eliminar cluster
kind delete cluster --name jenkins-dev

# Cargar imagen
kind load docker-image <imagen:tag> --name jenkins-dev

# Exportar logs
kind export logs --name jenkins-dev

# Obtener kubeconfig
kind get kubeconfig --name jenkins-dev
```

## Configuración Avanzada de Kind

Puedes crear un archivo de configuración para personalizar el cluster:

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
```

Luego crear el cluster:
```powershell
kind create cluster --name jenkins-dev --config kind-config.yaml
```

## Solución de Problemas

### Problema: Kind no puede cargar imagen

```powershell
# Verificar que la imagen existe localmente
docker images | grep order-service

# Cargar manualmente
kind load docker-image order-service:dev --name jenkins-dev
```

### Problema: Jenkins no puede acceder al cluster

```powershell
# Verificar kubeconfig
docker exec jenkins cat /var/jenkins_home/.kube/config

# Verificar contexto
docker exec jenkins kubectl config current-context

# Debería ser: kind-jenkins-dev
```

### Problema: Pods no pueden descargar imágenes

Asegúrate de usar `imagePullPolicy: Never` en tus deployments:

```yaml
spec:
  containers:
  - name: order-service
    image: order-service:dev
    imagePullPolicy: Never  # ← Importante
```

## Comparación: Kind vs Minikube vs Docker Desktop K8s

| | Kind | Minikube | Docker Desktop K8s |
|---|---|---|---|
| Instalación | Simple | Media | Ya incluido |
| Velocidad | Rápida | Media | Rápida |
| Recursos | Bajo | Medio | Bajo |
| Multi-nodo | Sí | Sí | No |
| Para CI/CD | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

## ¿Docker Desktop tiene Kubernetes?

Si tienes **Docker Desktop**, ya tiene Kubernetes integrado:

1. Abre Docker Desktop
2. Ve a Settings > Kubernetes
3. Marca "Enable Kubernetes"
4. Click "Apply & Restart"

Esto es aún más simple que Kind, pero Kind te da más control.

## Recomendación

Para tu caso (Jenkins + desarrollo local), te recomiendo:

1. **Primera opción: Kind** - Más control, mejor para CI/CD
2. **Segunda opción: Docker Desktop K8s** - Más simple si ya lo tienes
3. **Tercera opción: Minikube** - Si necesitas características avanzadas

## Próximos Pasos

1. Instalar Kind: `choco install kind`
2. Crear cluster: `kind create cluster --name jenkins-dev`
3. Copiar kubeconfig a Jenkins
4. Actualizar Jenkinsfiles para usar `kind load`
5. Probar un pipeline
