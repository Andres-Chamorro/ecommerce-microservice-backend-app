# 🚀 Guía Rápida de Inicio

## Para el Taller - Pasos Esenciales

### 📋 Lo que ya tienes
✅ 6 microservicios dockerizados:
- user-service
- product-service
- order-service
- payment-service
- favourite-service
- shipping-service

✅ Patrones implementados:
- API Gateway
- Service Discovery (Eureka)
- Cloud Config
- Distributed Tracing (Zipkin)

---

## 🎯 Objetivo del Taller

1. ✅ Configurar Jenkins, Docker y Kubernetes
2. ✅ Definir pipelines para construcción de aplicaciones (dev environment)
3. ⬜ Desplegar en la nube

---

## 🔥 Inicio Rápido (3 Pasos)

### Paso 1: Construir Imágenes Docker

**Windows:**
```powershell
.\build-all-images.ps1
```

**Linux/Mac:**
```bash
chmod +x build-all-images.sh
./build-all-images.sh
```

### Paso 2: Levantar Jenkins

```bash
docker-compose up -d jenkins
```

Acceder a: http://localhost:9000/jenkins
- Usuario: `admin`
- Contraseña: `admin123`

### Paso 3: Desplegar en Kubernetes

**Windows:**
```powershell
cd k8s
.\deploy-all.ps1
```

**Linux/Mac:**
```bash
cd k8s
chmod +x deploy-all.sh
./deploy-all.sh
```

---

## 📊 Verificar que Todo Funciona

```bash
# Ver todos los pods
kubectl get pods -n ecommerce-dev

# Ver servicios
kubectl get svc -n ecommerce-dev

# Acceder al API Gateway
kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev
```

Luego abrir: http://localhost:8080

---

## 🔄 Configurar Pipeline en Jenkins

### Crear un solo Pipeline Job:

1. En Jenkins → **New Item**
2. Nombre: `ecommerce-microservices`
3. Tipo: **Pipeline**
4. En **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: Tu repositorio
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. **Save**
6. **Build with Parameters** (puedes elegir qué servicios desplegar)

---

## ☁️ Desplegar en la Nube

### Opción 1: AWS EKS

```bash
# Instalar eksctl
# Crear cluster
eksctl create cluster --name ecommerce --region us-east-1 --nodes 3

# Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name ecommerce

# Desplegar
cd k8s
./deploy-all.sh
```

### Opción 2: Google Cloud (GKE)

```bash
# Crear cluster
gcloud container clusters create ecommerce \
  --zone us-central1-a \
  --num-nodes 3

# Configurar kubectl
gcloud container clusters get-credentials ecommerce --zone us-central1-a

# Desplegar
cd k8s
./deploy-all.sh
```

### Opción 3: Azure (AKS)

```bash
# Crear grupo de recursos
az group create --name ecommerce-rg --location eastus

# Crear cluster
az aks create \
  --resource-group ecommerce-rg \
  --name ecommerce \
  --node-count 3

# Configurar kubectl
az aks get-credentials --resource-group ecommerce-rg --name ecommerce

# Desplegar
cd k8s
./deploy-all.sh
```

---

## 📁 Estructura de Archivos Creados

```
ecommerce-microservice-backend-app/
├── k8s/
│   ├── namespace.yaml         # Namespace ecommerce-dev
│   ├── *-deployment.yaml      # Deployments y Services
│   ├── deploy-all.sh          # Script de despliegue (Linux/Mac)
│   ├── deploy-all.ps1         # Script de despliegue (Windows)
│   ├── delete-all.sh          # Script de limpieza (Linux/Mac)
│   └── delete-all.ps1         # Script de limpieza (Windows)
│
├── user-service/              # Microservicios
├── product-service/
├── order-service/
├── payment-service/
├── favourite-service/
├── shipping-service/
│
├── Jenkinsfile                # Pipeline CI/CD único
├── build-all-images.sh        # Construir todas las imágenes (Linux/Mac)
├── build-all-images.ps1       # Construir todas las imágenes (Windows)
├── JENKINS_KUBERNETES_SETUP.md # Guía completa
├── DEPLOY_DIGITALOCEAN.md     # Guía específica para DigitalOcean
└── QUICK_START.md             # Esta guía rápida
```

---

## 🎓 Conceptos del Taller

### Jenkins Pipeline Stages:
1. **Checkout** - Clonar código
2. **Build** - Compilar con Maven
3. **Unit Tests** - Ejecutar tests
4. **Code Quality** - Análisis de código
5. **Docker Build** - Crear imagen
6. **Docker Push** - Subir a registry
7. **K8s Deploy** - Desplegar en Kubernetes
8. **Smoke Tests** - Verificar funcionamiento

### Patrones de Microservicios:
- ✅ **API Gateway** - Punto de entrada único
- ✅ **Service Discovery** - Registro de servicios (Eureka)
- ✅ **Config Server** - Configuración centralizada
- ✅ **Distributed Tracing** - Trazabilidad (Zipkin)
- ✅ **Circuit Breaker** - Resilience4j
- ✅ **Load Balancing** - Kubernetes Service

---

## 🛠️ Comandos Útiles

### Docker
```bash
# Ver imágenes
docker images | grep ecommerce

# Ver contenedores
docker ps

# Logs de Jenkins
docker logs -f jenkins
```

### Kubernetes
```bash
# Ver todo en el namespace
kubectl get all -n ecommerce-dev

# Logs de un servicio
kubectl logs -f deployment/user-service -n ecommerce-dev

# Escalar servicio
kubectl scale deployment user-service --replicas=3 -n ecommerce-dev

# Reiniciar servicio
kubectl rollout restart deployment/user-service -n ecommerce-dev
```

### Jenkins
```bash
# Acceder a Jenkins
http://localhost:9000/jenkins

# Ver logs
docker logs jenkins
```

---

## 🐛 Solución de Problemas

### Jenkins no inicia
```bash
docker-compose down
docker-compose up -d jenkins
docker logs -f jenkins
```

### Pods no inician en K8s
```bash
kubectl describe pod <pod-name> -n ecommerce-dev
kubectl logs <pod-name> -n ecommerce-dev
```

### Imágenes no se encuentran
```bash
# Construir de nuevo
./build-all-images.ps1  # Windows
./build-all-images.sh   # Linux/Mac
```

---

## 📞 Checklist para el Taller

- [ ] Jenkins instalado y funcionando
- [ ] Kubernetes cluster activo
- [ ] Imágenes Docker construidas
- [ ] 6 microservicios desplegados en K8s
- [ ] Pipelines configurados en Jenkins
- [ ] API Gateway accesible
- [ ] Eureka mostrando servicios registrados
- [ ] Zipkin rastreando requests
- [ ] Despliegue en la nube (AWS/GCP/Azure)

---

## 🎉 ¡Listo para el Taller!

Ahora tienes:
1. ✅ Jenkins configurado con Docker y Kubernetes
2. ✅ Pipelines CI/CD para cada microservicio
3. ✅ Manifiestos de Kubernetes listos
4. ✅ Scripts de despliegue automatizados
5. ✅ Documentación completa

**Siguiente paso:** Desplegar en la nube (AWS EKS, Google GKE o Azure AKS)

---

Para más detalles, consulta: **JENKINS_KUBERNETES_SETUP.md**
