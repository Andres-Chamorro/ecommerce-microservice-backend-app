# Guía de Configuración: Jenkins, Docker y Kubernetes

## 📋 Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Configuración de Jenkins](#configuración-de-jenkins)
3. [Configuración de Kubernetes](#configuración-de-kubernetes)
4. [Despliegue de Microservicios](#despliegue-de-microservicios)
5. [Configuración de Pipelines CI/CD](#configuración-de-pipelines-cicd)
6. [Despliegue en la Nube](#despliegue-en-la-nube)

---

## 🔧 Requisitos Previos

### Software Necesario
- **Docker Desktop** (con Kubernetes habilitado) o **Minikube**
- **kubectl** CLI
- **Java 11** JDK
- **Maven 3.8+**
- **Git**

### Verificar Instalaciones
```bash
# Verificar Docker
docker --version

# Verificar Kubernetes
kubectl version --client

# Verificar Java
java -version

# Verificar Maven
mvn -version
```

---

## 🚀 Configuración de Jenkins

### Paso 1: Construir y Levantar Jenkins con Docker Compose

```bash
# Desde la raíz del proyecto
docker-compose up -d jenkins
```

### Paso 2: Acceder a Jenkins
- URL: http://localhost:9000/jenkins
- Usuario: `admin`
- Contraseña: `admin123` (cambiar en producción)

### Paso 3: Configurar Credenciales de Docker Hub

1. Ir a **Jenkins** → **Manage Jenkins** → **Manage Credentials**
2. Agregar credenciales de tipo **Username with password**
   - ID: `dockerhub`
   - Username: Tu usuario de Docker Hub
   - Password: Tu token de Docker Hub

### Paso 4: Crear Jobs de Pipeline

Para cada microservicio, crear un **Pipeline Job**:

1. **New Item** → Nombre del servicio (ej: `user-service`) → **Pipeline**
2. En **Pipeline** → **Definition**: Pipeline script from SCM
3. **SCM**: Git
4. **Repository URL**: URL de tu repositorio
5. **Script Path**: `user-service/Jenkinsfile`
6. Repetir para los 6 microservicios

---

## ☸️ Configuración de Kubernetes

### Opción A: Usar Docker Desktop Kubernetes

1. Abrir Docker Desktop
2. Settings → Kubernetes → Enable Kubernetes
3. Aplicar y reiniciar

### Opción B: Usar Minikube

```bash
# Iniciar Minikube
minikube start --cpus=4 --memory=8192

# Habilitar métricas
minikube addons enable metrics-server

# Verificar estado
minikube status
```

### Verificar Cluster
```bash
kubectl cluster-info
kubectl get nodes
```

---

## 📦 Despliegue de Microservicios

### Paso 1: Construir Imágenes Docker Localmente

```bash
# Desde la raíz del proyecto
./mvnw clean package

# Construir cada imagen (ejemplo para user-service)
docker build -t ecommerce-user-service:latest -f user-service/Dockerfile .
docker build -t ecommerce-product-service:latest -f product-service/Dockerfile .
docker build -t ecommerce-order-service:latest -f order-service/Dockerfile .
docker build -t ecommerce-payment-service:latest -f payment-service/Dockerfile .
docker build -t ecommerce-favourite-service:latest -f favourite-service/Dockerfile .
docker build -t ecommerce-shipping-service:latest -f shipping-service/Dockerfile .
```

### Paso 2: Desplegar en Kubernetes

#### Para Linux/Mac:
```bash
cd k8s
chmod +x deploy-all.sh
./deploy-all.sh
```

#### Para Windows PowerShell:
```powershell
cd k8s
.\deploy-all.ps1
```

### Paso 3: Verificar Despliegue

```bash
# Ver todos los pods
kubectl get pods -n ecommerce-dev

# Ver servicios
kubectl get svc -n ecommerce-dev

# Ver logs de un servicio específico
kubectl logs -f deployment/user-service -n ecommerce-dev
```

### Paso 4: Acceder a los Servicios

```bash
# API Gateway
kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev

# Eureka Dashboard
kubectl port-forward svc/service-discovery 8761:8761 -n ecommerce-dev

# Zipkin Dashboard
kubectl port-forward svc/zipkin 9411:9411 -n ecommerce-dev
```

Luego acceder a:
- API Gateway: http://localhost:8080
- Eureka: http://localhost:8761
- Zipkin: http://localhost:9411

---

## 🔄 Configuración de Pipelines CI/CD

### Flujo del Pipeline

Cada microservicio tiene su propio Jenkinsfile con las siguientes etapas:

1. **Checkout**: Clonar el código fuente
2. **Build**: Compilar con Maven
3. **Unit Tests**: Ejecutar pruebas unitarias
4. **Code Quality Analysis**: Análisis de calidad
5. **Build Docker Image**: Construir imagen Docker
6. **Push Docker Image**: Subir a Docker Registry (solo en rama `main`)
7. **Deploy to Kubernetes**: Desplegar en K8s (solo en rama `main`)
8. **Smoke Tests**: Verificar que el servicio está funcionando

### Ejecutar Pipeline Manualmente

1. Ir a Jenkins → Seleccionar el job del microservicio
2. Click en **Build Now**
3. Ver el progreso en **Console Output**

### Pipeline Automático con Webhooks

Para configurar builds automáticos al hacer push:

1. En Jenkins, ir al job → **Configure**
2. En **Build Triggers**, seleccionar **GitHub hook trigger for GITScm polling**
3. En GitHub, ir a **Settings** → **Webhooks** → **Add webhook**
4. Payload URL: `http://tu-jenkins-url/github-webhook/`
5. Content type: `application/json`
6. Eventos: **Just the push event**

---

## ☁️ Despliegue en la Nube

### Opción 1: Amazon EKS (AWS)

#### Prerequisitos
```bash
# Instalar AWS CLI
# Instalar eksctl
```

#### Crear Cluster
```bash
eksctl create cluster \
  --name ecommerce-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

#### Configurar kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name ecommerce-cluster
```

#### Desplegar
```bash
cd k8s
./deploy-all.sh
```

### Opción 2: Google Kubernetes Engine (GKE)

#### Prerequisitos
```bash
# Instalar gcloud CLI
gcloud init
```

#### Crear Cluster
```bash
gcloud container clusters create ecommerce-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type n1-standard-2
```

#### Configurar kubectl
```bash
gcloud container clusters get-credentials ecommerce-cluster --zone us-central1-a
```

#### Desplegar
```bash
cd k8s
./deploy-all.sh
```

### Opción 3: Azure Kubernetes Service (AKS)

#### Prerequisitos
```bash
# Instalar Azure CLI
az login
```

#### Crear Resource Group y Cluster
```bash
# Crear grupo de recursos
az group create --name ecommerce-rg --location eastus

# Crear cluster AKS
az aks create \
  --resource-group ecommerce-rg \
  --name ecommerce-cluster \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2 \
  --enable-addons monitoring \
  --generate-ssh-keys
```

#### Configurar kubectl
```bash
az aks get-credentials --resource-group ecommerce-rg --name ecommerce-cluster
```

#### Desplegar
```bash
cd k8s
./deploy-all.sh
```

---

## 📊 Monitoreo y Observabilidad

### Zipkin (Distributed Tracing)
- URL: http://localhost:9411 (con port-forward)
- Permite rastrear requests entre microservicios

### Eureka (Service Discovery)
- URL: http://localhost:8761 (con port-forward)
- Ver todos los servicios registrados

### Kubernetes Dashboard

```bash
# Instalar dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Crear usuario admin
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin

# Obtener token
kubectl -n kubernetes-dashboard create token dashboard-admin

# Acceder al dashboard
kubectl proxy
```

Luego ir a: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

---

## 🧪 Testing

### Probar un Microservicio

```bash
# Port-forward al API Gateway
kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev

# Probar endpoint (ejemplo: user-service)
curl http://localhost:8080/user-service/actuator/health
```

### Escalar un Servicio

```bash
# Escalar replicas
kubectl scale deployment user-service --replicas=3 -n ecommerce-dev

# Verificar
kubectl get pods -n ecommerce-dev -l app=user-service
```

---

## 🔧 Troubleshooting

### Ver logs de un pod
```bash
kubectl logs -f <pod-name> -n ecommerce-dev
```

### Describir un pod con problemas
```bash
kubectl describe pod <pod-name> -n ecommerce-dev
```

### Reiniciar un deployment
```bash
kubectl rollout restart deployment/<service-name> -n ecommerce-dev
```

### Eliminar todo y empezar de nuevo
```bash
cd k8s
./delete-all.sh  # Linux/Mac
# o
.\delete-all.ps1  # Windows
```

---

## 📚 Recursos Adicionales

- [Documentación de Kubernetes](https://kubernetes.io/docs/)
- [Documentación de Jenkins](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)

---

## 🎯 Próximos Pasos

1. ✅ Configurar Jenkins
2. ✅ Configurar Kubernetes
3. ✅ Desplegar microservicios localmente
4. ⬜ Configurar pipelines automáticos
5. ⬜ Desplegar en la nube (AWS/GCP/Azure)
6. ⬜ Configurar monitoreo avanzado (Prometheus + Grafana)
7. ⬜ Implementar Ingress Controller
8. ⬜ Configurar SSL/TLS

---

## 📝 Notas Importantes

- **Seguridad**: Cambiar las contraseñas por defecto en producción
- **Recursos**: Ajustar los límites de CPU/memoria según tu infraestructura
- **Persistencia**: Configurar volúmenes persistentes para bases de datos
- **Backup**: Implementar estrategia de backup para datos críticos
- **Secrets**: Usar Kubernetes Secrets para información sensible

---

**¡Buena suerte con tu proyecto! 🚀**
