# 🚀 Quick Start - GCP Deployment

## ✅ Lo que ya tienes preparado:

1. ✅ Google Cloud SDK instalándose
2. ✅ Cuenta GCP con $300 créditos
3. ✅ Scripts creados:
   - `build-and-push-gcp.ps1`
   - `update-k8s-images-gcp.ps1`
   - `Jenkinsfile.gcp`
4. ✅ Guía completa en `SETUP_GCP.md`

---

## 🎯 Pasos Rápidos (2-3 horas)

### 1️⃣ Configurar GCP (30 min)

```powershell
# Después de que termine de instalarse gcloud, reinicia PowerShell

# Autenticar
gcloud auth login

# Crear proyecto (o usa uno existente)
gcloud projects create ecommerce-microservices-XXXX --name="Ecommerce Microservices"

# Configurar proyecto
gcloud config set project TU-PROJECT-ID

# Habilitar APIs
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable compute.googleapis.com
```

### 2️⃣ Crear Artifact Registry (5 min)

```powershell
gcloud artifacts repositories create ecommerce-registry `
  --repository-format=docker `
  --location=us-central1 `
  --description="Container registry for ecommerce microservices"
```

### 3️⃣ Crear GKE Cluster (15 min - tarda en crearse)

```powershell
gcloud container clusters create ecommerce-staging-cluster `
  --zone=us-central1-a `
  --num-nodes=3 `
  --machine-type=e2-medium `
  --disk-size=30GB
```

### 4️⃣ Conectar kubectl (2 min)

```powershell
gcloud container clusters get-credentials ecommerce-staging-cluster --zone=us-central1-a

kubectl get nodes
```

### 5️⃣ Crear Namespaces (2 min)

```powershell
kubectl create namespace ecommerce-staging
kubectl create namespace ecommerce-dev
```

### 6️⃣ Build y Push Imágenes (30 min)

```powershell
# Autenticar Docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build y push
.\build-and-push-gcp.ps1
# Te pedirá tu PROJECT_ID
```

### 7️⃣ Actualizar Manifiestos K8s (2 min)

```powershell
.\update-k8s-images-gcp.ps1
# Te pedirá tu PROJECT_ID
```

### 8️⃣ Desplegar en GKE (10 min)

```powershell
# Infraestructura
kubectl apply -f k8s/infrastructure/ -n ecommerce-staging

# Esperar un poco...
Start-Sleep -Seconds 60

# Microservicios
kubectl apply -f k8s/microservices/ -n ecommerce-staging

# Verificar
kubectl get pods -n ecommerce-staging
```

### 9️⃣ Obtener IP Pública (5 min)

```powershell
# Ver servicios
kubectl get services -n ecommerce-staging

# Esperar a que se asigne IP externa
kubectl get service api-gateway -n ecommerce-staging --watch
# Presiona Ctrl+C cuando veas la IP
```

### 🔟 Probar la Aplicación (5 min)

```powershell
# Obtener IP
$API_IP = kubectl get service api-gateway -n ecommerce-staging -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Probar
curl http://${API_IP}:8080/actuator/health
curl http://${API_IP}:8080/api/users
curl http://${API_IP}:8080/api/products
```

---

## 🎯 Configurar Jenkins (Opcional - 20 min)

### 1. Crear Service Account

```powershell
# Crear service account
gcloud iam service-accounts create jenkins-gke --display-name="Jenkins GKE"

# Dar permisos
$PROJECT_ID = gcloud config get-value project
$SA_EMAIL = "jenkins-gke@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${SA_EMAIL}" `
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${SA_EMAIL}" `
  --role="roles/artifactregistry.writer"

# Crear key
gcloud iam service-accounts keys create jenkins-gke-key.json --iam-account=$SA_EMAIL
```

### 2. Configurar en Jenkins

1. Ve a: http://localhost:9090
2. Manage Jenkins → Credentials → Add
3. Tipo: **Secret file**
4. File: `jenkins-gke-key.json`
5. ID: `gcp-service-account`

### 3. Agregar Project ID

1. Add Credentials
2. Tipo: **Secret text**
3. Secret: Tu PROJECT_ID
4. ID: `gcp-project-id`

### 4. Crear Pipeline

1. New Item → Pipeline
2. Name: `ecommerce-gcp-staging`
3. Script Path: `Jenkinsfile.gcp`
4. Branch: `*/staging`

---

## 💰 Costos

- GKE (3 nodos e2-medium): ~$75/mes
- Artifact Registry: GRATIS
- Load Balancer: ~$18/mes
- **Total: ~$93/mes**
- **Con $300: ~3.2 meses GRATIS**

---

## 🆘 Comandos Útiles

```powershell
# Ver pods
kubectl get pods -n ecommerce-staging

# Ver logs
kubectl logs <pod-name> -n ecommerce-staging

# Reiniciar deployment
kubectl rollout restart deployment/user-service -n ecommerce-staging

# Ver eventos
kubectl get events -n ecommerce-staging --sort-by='.lastTimestamp'

# Escalar deployment
kubectl scale deployment/user-service --replicas=3 -n ecommerce-staging

# Ver imágenes en registry
gcloud artifacts docker images list us-central1-docker.pkg.dev/$PROJECT_ID/ecommerce-registry
```

---

## 📚 Links Útiles

- **GCP Console:** https://console.cloud.google.com/
- **GKE Workloads:** https://console.cloud.google.com/kubernetes/workload
- **Artifact Registry:** https://console.cloud.google.com/artifacts
- **Guía Completa:** Ver `SETUP_GCP.md`

---

## ✅ Checklist

- [ ] gcloud CLI instalado
- [ ] Autenticado con GCP
- [ ] Proyecto configurado
- [ ] APIs habilitadas
- [ ] Artifact Registry creado
- [ ] GKE Cluster creado
- [ ] kubectl conectado
- [ ] Namespaces creados
- [ ] Imágenes construidas y subidas
- [ ] Manifiestos actualizados
- [ ] Aplicación desplegada
- [ ] IP pública obtenida
- [ ] Aplicación funcionando

¡Éxito! 🚀
