# Configuración Completa: Jenkins + Minikube

## Estado Actual

❌ **Minikube NO está instalado**
✅ kubectl está instalado (v1.32.2)
❓ Jenkins - necesita verificación

## Pasos para Configurar Todo

### 1. Instalar Minikube

Tienes 3 opciones:

#### Opción A: Usando Chocolatey (Recomendado)
```powershell
# Si tienes Chocolatey instalado
choco install minikube
```

#### Opción B: Descarga Manual
1. Ve a: https://minikube.sigs.k8s.io/docs/start/
2. Descarga el instalador para Windows
3. Ejecuta el instalador
4. Reinicia PowerShell

#### Opción C: Usando winget
```powershell
winget install Kubernetes.minikube
```

### 2. Verificar Instalación de Minikube

Después de instalar, cierra y abre PowerShell, luego ejecuta:

```powershell
minikube version
```

### 3. Iniciar Minikube

```powershell
# Iniciar Minikube con Docker como driver
minikube start --driver=docker

# Verificar que está corriendo
minikube status
```

### 4. Ejecutar Script de Configuración

Una vez que Minikube esté instalado y corriendo:

```powershell
./scripts/setup-jenkins-minikube-complete.ps1
```

Este script:
- ✅ Verifica que Minikube esté corriendo
- ✅ Obtiene la IP de Minikube
- ✅ Verifica conectividad con Kubernetes
- ✅ Crea el namespace `ecommerce-dev`
- ✅ Verifica que Jenkins tenga acceso a kubectl
- ✅ Te da los próximos pasos

### 5. Configurar Jenkins para Acceder a Minikube

#### 5.1 Copiar kubeconfig a Jenkins

```powershell
# Crear directorio .kube en Jenkins si no existe
docker exec jenkins mkdir -p /var/jenkins_home/.kube

# Copiar kubeconfig
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

# Dar permisos
docker exec jenkins chmod 644 /var/jenkins_home/.kube/config
```

#### 5.2 Verificar que Jenkins puede acceder a Kubernetes

```powershell
# Probar kubectl desde Jenkins
docker exec jenkins kubectl get nodes

# Debería mostrar el nodo de Minikube
```

### 6. Configurar Jenkins para Usar Docker de Minikube

Jenkins necesita construir imágenes que Minikube pueda usar. Hay 2 enfoques:

#### Enfoque A: Jenkins usa el Docker daemon de Minikube (Recomendado)

Esto requiere que Jenkins se conecte al Docker daemon de Minikube.

```powershell
# Obtener la configuración de Docker de Minikube
minikube docker-env

# Esto te dará variables como:
# DOCKER_HOST=tcp://192.168.x.x:2376
# DOCKER_CERT_PATH=...
# DOCKER_TLS_VERIFY=1
```

Luego configura estas variables en Jenkins (Manage Jenkins > Configure System > Global Properties > Environment variables)

#### Enfoque B: Construir en Jenkins y cargar a Minikube

En el Jenkinsfile, después de construir la imagen:

```groovy
// Guardar imagen
sh 'docker save ${IMAGE_NAME}:${BUILD_TAG} -o image.tar'

// Cargar en Minikube
sh 'minikube image load image.tar'
```

### 7. Probar un Pipeline

1. Ve a Jenkins: http://localhost:8080
2. Crea un nuevo pipeline o usa uno existente
3. Ejecuta el pipeline de `order-service`
4. Verifica que:
   - Se construya la imagen Docker
   - Se despliegue en Minikube
   - El pod esté corriendo

```powershell
# Ver pods desplegados
kubectl get pods -n ecommerce-dev

# Ver servicios
kubectl get svc -n ecommerce-dev
```

## Solución de Problemas

### Problema: Minikube no inicia

```powershell
# Eliminar cluster existente
minikube delete

# Iniciar de nuevo
minikube start --driver=docker
```

### Problema: Jenkins no puede conectarse a Kubernetes

```powershell
# Verificar que el kubeconfig esté en Jenkins
docker exec jenkins cat /var/jenkins_home/.kube/config

# Verificar conectividad desde Jenkins
docker exec jenkins kubectl cluster-info
```

### Problema: Imágenes no se encuentran en Minikube

```powershell
# Ver imágenes en Minikube
minikube ssh docker images

# Cargar imagen manualmente
minikube image load nombre-imagen:tag
```

### Problema: Pods en estado ImagePullBackOff

Esto significa que Kubernetes no puede encontrar la imagen. Soluciones:

1. Asegúrate de usar `imagePullPolicy: Never` en el deployment
2. Verifica que la imagen esté en Minikube: `minikube ssh docker images`
3. Construye la imagen usando el Docker de Minikube

## Comandos Útiles

```powershell
# Ver estado de Minikube
minikube status

# Ver IP de Minikube
minikube ip

# Acceder al dashboard
minikube dashboard

# Ver logs de un pod
kubectl logs <pod-name> -n ecommerce-dev

# Describir un pod (para debugging)
kubectl describe pod <pod-name> -n ecommerce-dev

# Eliminar todos los deployments
kubectl delete all --all -n ecommerce-dev

# SSH a Minikube
minikube ssh

# Detener Minikube
minikube stop

# Eliminar Minikube
minikube delete
```

## Próximos Pasos Después de la Configuración

1. ✅ Instalar Minikube
2. ✅ Ejecutar script de configuración
3. ✅ Copiar kubeconfig a Jenkins
4. ✅ Configurar Docker de Minikube en Jenkins
5. ✅ Probar un pipeline
6. ✅ Verificar que el servicio se despliegue correctamente

## Notas Importantes

- Minikube es solo para desarrollo local
- Las imágenes en Minikube son independientes de tu Docker local
- Cada vez que reconstruyas Minikube, perderás las imágenes y deployments
- Para producción, usa un cluster real (GKE, EKS, AKS, etc.)
