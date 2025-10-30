# 🚀 Guía de Configuración Google Cloud Platform (GCP)

## 📋 FASE 1: Configuración Inicial (20 min)

### 1. Verificar cuenta y créditos
- Ve a: https://console.cloud.google.com/
- Verifica que tienes $300 de créditos activos
- Deberías ver "Free Trial" activo

### 2. Crear proyecto
1. Click en selector de proyectos (arriba)
2. **"New Project"**
3. Configuración:
   - Project name: `ecommerce-microservices`
   - Project ID: (se genera automático, cópialo)
4. Click **"Create"**

### 3. Habilitar APIs necesarias
Ve a: https://console.cloud.google.com/apis/library

Habilita las siguientes APIs:
- ✅ **Kubernetes Engine API**
- ✅ **Artifact Registry API**
- ✅ **Container Registry API**
- ✅ **Compute Engine API**
- ✅ **Cloud Build API**

O desde CLI:
```powershell
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

---

## 📋 FASE 2: Instalar Herramientas (15 min)

### 1. Instalar Google Cloud SDK

**Con winget:**
```powershell
winget install Google.CloudSDK
```

**O descarga manual:**
- https://cloud.google.com/sdk/docs/install

**Verificar instalación:**
```powershell
gcloud version
```

### 2. Verificar kubectl
```powershell
kubectl version --client
```

Si no lo tienes:
```powershell
gcloud components install kubectl
```

---

## 📋 FASE 3: Autenticar y Configurar (10 min)

### 1. Autenticar con GCP
```powershell
# Login con tu cuenta de Google
gcloud auth login

# Se abrirá el navegador, autoriza el acceso
```

### 2. Configurar proyecto por defecto
```powershell
# Reemplaza PROJECT_ID con tu ID de proyecto
gcloud config set project PROJECT_ID

# Verificar
gcloud config get-value project
```

### 3. Configurar región por defecto
```powershell
# Usar us-central1 (Iowa) - más económico
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

### 4. Configurar Docker para GCP
```powershell
# Autenticar Docker con GCP
gcloud auth configure-docker

# Para Artifact Registry (recomendado)
gcloud auth configure-docker us-central1-docker.pkg.dev
```

---

## 📋 FASE 4: Crear Artifact Registry (10 min)

### Opción A: Desde la consola web

1. Ve a: https://console.cloud.google.com/artifacts
2. Click **"Create Repository"**
3. Configuración:
   - **Name:** `ecommerce-registry`
   - **Format:** Docker
   - **Mode:** Standard
   - **Location type:** Region
   - **Region:** us-central1 (Iowa)
   - **Encryption:** Google-managed key
4. Click **"Create"**

### Opción B: Desde CLI (más rápido)

```powershell
gcloud artifacts repositories create ecommerce-registry `
  --repository-format=docker `
  --location=us-central1 `
  --description="Container registry for ecommerce microservices"
```

**Verificar:**
```powershell
gcloud artifacts repositories list
```

---

## 📋 FASE 5: Crear Cluster de Kubernetes (GKE) (15 min)

### Opción A: Desde la consola web

1. Ve a: https://console.cloud.google.com/kubernetes
2. Click **"Create Cluster"**
3. Selecciona **"GKE Standard"** (no Autopilot)
4. Configuración:

   **Cluster basics:**
   - Name: `ecommerce-staging-cluster`
   - Location type: **Zonal**
   - Zone: `us-central1-a`

   **Node Pools → default-pool:**
   - Number of nodes: **3**
   - Machine type: **e2-medium** (2 vCPU, 4 GB)
   - Boot disk size: 30 GB
   - Enable autoscaling: No (para empezar)

   **Cluster:**
   - Release channel: **Regular**
   - Version: Latest stable

5. Click **"Create"** (toma 5-7 minutos)

### Opción B: Desde CLI (recomendado)

```powershell
gcloud container clusters create ecommerce-staging-cluster `
  --zone=us-central1-a `
  --num-nodes=3 `
  --machine-type=e2-medium `
  --disk-size=30GB `
  --enable-autoupgrade `
  --enable-autorepair `
  --no-enable-autoscaling
```

**Monitorear creación:**
```powershell
gcloud container clusters list
```

---

## 📋 FASE 6: Conectar kubectl al Cluster (5 min)

### 1. Obtener credenciales del cluster

```powershell
gcloud container clusters get-credentials ecommerce-staging-cluster `
  --zone=us-central1-a
```

### 2. Verificar conexión

```powershell
# Ver nodos
kubectl get nodes

# Ver contexto actual
kubectl config current-context
```

Deberías ver 3 nodos en estado `Ready`.

---

## 📋 FASE 7: Crear Namespaces (5 min)

```powershell
# Crear namespace para staging
kubectl create namespace ecommerce-staging

# Crear namespace para dev (opcional)
kubectl create namespace ecommerce-dev

# Crear namespace para prod (opcional)
kubectl create namespace ecommerce-prod

# Verificar
kubectl get namespaces
```

---

## 📋 FASE 8: Preparar Imágenes Docker (30 min)

### 1. Configurar variables de entorno

```powershell
# Reemplaza con tu PROJECT_ID
$PROJECT_ID = "ecommerce-microservices-XXXX"
$REGION = "us-central1"
$REGISTRY = "${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-registry"

# Verificar
echo $REGISTRY
```

### 2. Actualizar scripts para GCP

El script `build-and-push-gcp.ps1` ya está creado (ver abajo).

### 3. Build y Push de imágenes

```powershell
# Ejecutar script
.\build-and-push-gcp.ps1
```

Este proceso tomará ~20-30 minutos.

---

## 📋 FASE 9: Actualizar Manifiestos de Kubernetes (10 min)

### 1. Actualizar imágenes en manifiestos

```powershell
# Ejecutar script
.\update-k8s-images-gcp.ps1
```

### 2. Verificar cambios

```powershell
# Ver un ejemplo
cat k8s\microservices\user-service-deployment.yaml
```

Deberías ver imágenes como:
```yaml
image: us-central1-docker.pkg.dev/PROJECT_ID/ecommerce-registry/ecommerce-user-service:latest
```

---

## 📋 FASE 10: Desplegar en GKE (15 min)

### 1. Desplegar infraestructura

```powershell
# Aplicar manifiestos de infraestructura
kubectl apply -f k8s/infrastructure/ -n ecommerce-staging

# Verificar
kubectl get pods -n ecommerce-staging
```

### 2. Esperar a que la infraestructura esté lista

```powershell
# Esperar a service-discovery
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce-staging --timeout=300s

# Esperar a cloud-config
kubectl wait --for=condition=ready pod -l app=cloud-config -n ecommerce-staging --timeout=300s
```

### 3. Desplegar microservicios

```powershell
# Aplicar manifiestos de microservicios
kubectl apply -f k8s/microservices/ -n ecommerce-staging

# Verificar
kubectl get pods -n ecommerce-staging
kubectl get services -n ecommerce-staging
```

### 4. Obtener IP pública del Load Balancer

```powershell
# Ver servicios
kubectl get service api-gateway -n ecommerce-staging

# Esperar a que se asigne IP externa (puede tomar 2-3 min)
kubectl get service api-gateway -n ecommerce-staging --watch
```

---

## 📋 FASE 11: Configurar Jenkins para GCP (20 min)

### 1. Crear Service Account para Jenkins

```powershell
# Crear service account
gcloud iam service-accounts create jenkins-gke `
  --display-name="Jenkins GKE Deployer"

# Obtener email del service account
$SA_EMAIL = "jenkins-gke@${PROJECT_ID}.iam.gserviceaccount.com"

# Dar permisos necesarios
gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${SA_EMAIL}" `
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${SA_EMAIL}" `
  --role="roles/artifactregistry.writer"

# Crear key JSON
gcloud iam service-accounts keys create jenkins-gke-key.json `
  --iam-account=$SA_EMAIL
```

### 2. Configurar credenciales en Jenkins

1. Ve a: http://localhost:9090
2. Manage Jenkins → Credentials → System → Global credentials
3. Click **"Add Credentials"**
4. Configuración:
   - Kind: **Secret file**
   - File: Selecciona `jenkins-gke-key.json`
   - ID: `gcp-service-account`
   - Description: `GCP Service Account for Jenkins`
5. Click **"Create"**

### 3. Agregar Project ID como credencial

1. Add Credentials
2. Configuración:
   - Kind: **Secret text**
   - Secret: Tu PROJECT_ID
   - ID: `gcp-project-id`
   - Description: `GCP Project ID`
3. Click **"Create"**

---

## 📋 FASE 12: Crear Pipeline en Jenkins (15 min)

### 1. Crear Pipeline Job

1. Jenkins → New Item
2. Name: `ecommerce-gcp-staging`
3. Type: **Pipeline**
4. Click **OK**

### 2. Configurar Pipeline

1. En la configuración del job:
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** (tu repo o ruta local)
   - **Branch:** `*/staging`
   - **Script Path:** `Jenkinsfile.gcp`
2. Click **Save**

### 3. Ejecutar Pipeline

1. Click **"Build Now"**
2. Monitorea el progreso en **Console Output**

---

## 📋 FASE 13: Verificar Deployment (10 min)

### 1. Verificar pods

```powershell
kubectl get pods -n ecommerce-staging
```

Todos deberían estar en estado `Running`.

### 2. Verificar servicios

```powershell
kubectl get services -n ecommerce-staging
```

### 3. Obtener IP externa

```powershell
$API_IP = kubectl get service api-gateway -n ecommerce-staging -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo "API Gateway: http://${API_IP}:8080"
```

### 4. Probar API Gateway

```powershell
# Health check
curl http://${API_IP}:8080/actuator/health

# Verificar servicios
curl http://${API_IP}:8080/api/users
curl http://${API_IP}:8080/api/products
```

---

## 📋 FASE 14: Ejecutar Pruebas (30 min)

### 1. Smoke Tests

```powershell
# Health check
curl http://${API_IP}:8080/actuator/health

# Verificar endpoints
curl http://${API_IP}:8080/api/users
curl http://${API_IP}:8080/api/products
curl http://${API_IP}:8080/api/orders
```

### 2. Integration Tests

```powershell
# Configurar variable de entorno
$env:API_BASE_URL = "http://${API_IP}:8080"

# Ejecutar tests
mvn verify -Pintegration-tests
```

### 3. E2E Tests

```powershell
# Ejecutar E2E tests
mvn test -pl tests/e2e -Dtest.url=http://${API_IP}:8080
```

### 4. Performance Tests (Locust)

```powershell
cd tests/performance
locust -f locustfile.py --host=http://${API_IP}:8080 --headless -u 10 -r 2 -t 60s
```

---

## ✅ Checklist Final

- [ ] Cuenta GCP creada con $300 créditos
- [ ] Proyecto creado
- [ ] APIs habilitadas
- [ ] gcloud CLI instalado y autenticado
- [ ] Artifact Registry creado
- [ ] GKE Cluster creado (3 nodos)
- [ ] kubectl conectado al cluster
- [ ] Namespaces creados
- [ ] Imágenes Docker subidas a Artifact Registry
- [ ] Infraestructura desplegada en GKE
- [ ] Microservicios desplegados en GKE
- [ ] Jenkins configurado con service account
- [ ] Pipeline ejecutado exitosamente
- [ ] Pruebas ejecutadas contra GKE

---

## 💰 Costo Estimado

- GKE Cluster (3 nodos e2-medium): ~$75/mes
- Artifact Registry: GRATIS
- Load Balancer: ~$18/mes
- Almacenamiento y red: ~$5/mes
- **Total: ~$98/mes**
- **Con $300 créditos: GRATIS por ~3 meses**

---

## 🆘 Troubleshooting

### Problema: Pods en estado Pending
```powershell
kubectl describe pod <pod-name> -n ecommerce-staging
```

### Problema: ImagePullBackOff
```powershell
# Verificar autenticación
gcloud auth configure-docker us-central1-docker.pkg.dev

# Verificar que las imágenes existen
gcloud artifacts docker images list us-central1-docker.pkg.dev/PROJECT_ID/ecommerce-registry
```

### Problema: No se asigna IP externa
```powershell
# Verificar servicio
kubectl get service api-gateway -n ecommerce-staging -o yaml

# Verificar firewall rules
gcloud compute firewall-rules list
```

### Ver logs de un pod
```powershell
kubectl logs <pod-name> -n ecommerce-staging
kubectl logs <pod-name> -n ecommerce-staging --previous
```

### Reiniciar un deployment
```powershell
kubectl rollout restart deployment/<deployment-name> -n ecommerce-staging
```

### Ver eventos del cluster
```powershell
kubectl get events -n ecommerce-staging --sort-by='.lastTimestamp'
```

---

## 📚 Recursos Útiles

- GCP Console: https://console.cloud.google.com/
- GKE Docs: https://cloud.google.com/kubernetes-engine/docs
- Artifact Registry: https://cloud.google.com/artifact-registry/docs
- gcloud CLI Reference: https://cloud.google.com/sdk/gcloud/reference

---

## 🎯 Ventajas de GCP vs DigitalOcean

✅ **$300 créditos** vs $200
✅ **Artifact Registry GRATIS** (ilimitado)
✅ **Mejor integración** con Google services
✅ **Más potente** y escalable
✅ **Mejor documentación**
✅ **Autopilot mode** disponible (opcional)

¡Éxito con tu deployment en GCP! 🚀
