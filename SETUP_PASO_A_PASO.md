# 🚀 Guía Paso a Paso - Configuración del Taller

## 📋 Estado Actual

✅ Ramas Git (dev, staging, master) - **COMPLETADO**  
✅ Jenkinsfiles creados (18 archivos) - **COMPLETADO**  
✅ Pruebas implementadas (83 pruebas) - **COMPLETADO**  
❌ Docker Registry (GCR) - **PENDIENTE**  
❌ Minikube - **PENDIENTE**  
❌ Pipelines en Jenkins - **PENDIENTE**

---

## 🎯 PASO 1: Configurar Google Container Registry (GCR)

### 1.1 Actualizar Jenkinsfiles con GCR

Ejecuta este comando en PowerShell:

```powershell
.\scripts\update-jenkinsfiles-registry.ps1
```

**Resultado esperado**:
```
✅ 18 archivos actualizados
Registry configurado: us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry
```

---

### 1.2 Configurar GCR en GCP

Ejecuta este comando en Git Bash o WSL:

```bash
bash scripts/setup-gcr.sh
```

**Resultado esperado**:
```
✅ Artifact Registry API habilitada
✅ Repositorio 'ecommerce-registry' creado
✅ Docker autenticado con GCR
✅ Registry funcionando correctamente
```

**Si no tienes Git Bash o WSL**, ejecuta manualmente:

```powershell
# 1. Habilitar Artifact Registry API
gcloud services enable artifactregistry.googleapis.com --project=ecommerce-microservices-476519

# 2. Crear repositorio (si no existe)
gcloud artifacts repositories create ecommerce-registry `
    --repository-format=docker `
    --location=us-central1 `
    --description="Docker registry para microservicios de ecommerce" `
    --project=ecommerce-microservices-476519

# 3. Configurar autenticación
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

# 4. Probar el registry
docker pull hello-world:latest
docker tag hello-world:latest us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry/hello-world:test
docker push us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry/hello-world:test
```

---

### 1.3 Verificar que funciona

```bash
# Listar imágenes en el registry
gcloud artifacts docker images list us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry
```

**Deberías ver**: La imagen `hello-world:test`

---

## 🎯 PASO 2: Instalar Minikube (para ambiente DEV)

### 2.1 Instalar Minikube

**En Windows con PowerShell (Administrador)**:

```powershell
# Descargar Minikube
New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing

# Agregar al PATH
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube'){
  [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
}

# Reiniciar PowerShell y verificar
minikube version
```

---

### 2.2 Iniciar Minikube

```powershell
# Iniciar Minikube con Docker driver
minikube start --driver=docker --cpus=4 --memory=8192

# Verificar que funciona
kubectl get nodes
minikube status
```

**Resultado esperado**:
```
✅ minikube
✅ type: Control Plane
✅ host: Running
✅ kubelet: Running
```

---

### 2.3 Configurar Minikube para usar GCR

```bash
# Configurar credenciales de GCP en Minikube
minikube ssh "docker login -u _json_key --password-stdin https://us-central1-docker.pkg.dev < /path/to/jenkins-gcp-key.json"
```

**Alternativa**: Crear un secret en Kubernetes

```bash
kubectl create secret docker-registry gcr-secret \
  --docker-server=us-central1-docker.pkg.dev \
  --docker-username=_json_key \
  --docker-password="$(cat jenkins-gcp-key.json)" \
  --namespace=ecommerce-dev
```

---

## 🎯 PASO 3: Configurar Jenkins para usar GCR

### 3.1 Configurar credenciales en Jenkins

1. Ir a Jenkins → Manage Jenkins → Manage Credentials
2. Click en "(global)" → Add Credentials
3. Configurar:
   - **Kind**: Secret file
   - **File**: Subir `jenkins-gcp-key.json`
   - **ID**: `gcp-service-account-key`
   - **Description**: GCP Service Account for GCR

---

### 3.2 Actualizar Jenkinsfiles para usar credenciales

Los Jenkinsfiles ya están configurados para usar el registry de GCR. Solo necesitas asegurarte de que Jenkins tenga acceso al archivo `jenkins-gcp-key.json`.

---

## 🎯 PASO 4: Crear Pipelines en Jenkins

### 4.1 Crear Pipeline para DEV (Ejemplo: user-service)

1. **Jenkins** → New Item
2. **Nombre**: `user-service-dev-pipeline`
3. **Tipo**: Multibranch Pipeline
4. **Configurar**:
   - **Branch Sources**: Git
   - **Project Repository**: `https://github.com/tu-usuario/ecommerce-microservice-backend-app.git`
   - **Credentials**: (tus credenciales de GitHub)
   - **Behaviors**: 
     - Discover branches
     - Filter by name (with regular expression): `dev`
   - **Build Configuration**:
     - Mode: `by Jenkinsfile`
     - Script Path: `user-service/Jenkinsfile.dev`
5. **Save**

---

### 4.2 Repetir para todos los servicios

**DEV Pipelines (6)**:
- `user-service-dev-pipeline` → `user-service/Jenkinsfile.dev` (rama: `dev`)
- `product-service-dev-pipeline` → `product-service/Jenkinsfile.dev` (rama: `dev`)
- `order-service-dev-pipeline` → `order-service/Jenkinsfile.dev` (rama: `dev`)
- `payment-service-dev-pipeline` → `payment-service/Jenkinsfile.dev` (rama: `dev`)
- `favourite-service-dev-pipeline` → `favourite-service/Jenkinsfile.dev` (rama: `dev`)
- `shipping-service-dev-pipeline` → `shipping-service/Jenkinsfile.dev` (rama: `dev`)

**STAGING Pipelines (6)**:
- Mismo proceso pero con rama `staging` y `Jenkinsfile.staging`

**MASTER Pipelines (6)**:
- Mismo proceso pero con rama `master` y `Jenkinsfile.master`

---

## 🎯 PASO 5: Probar el Flujo Completo

### 5.1 Probar Pipeline DEV

```bash
# Hacer un cambio en dev
git checkout dev
echo "# Test" >> README.md
git add .
git commit -m "test: probar pipeline dev"
git push origin dev
```

**Ir a Jenkins** → `user-service-dev-pipeline` → Debería ejecutarse automáticamente

---

### 5.2 Probar Pipeline STAGING

```bash
# Merge a staging
git checkout staging
git merge dev
git push origin staging
```

**Ir a Jenkins** → `user-service-staging-pipeline` → Debería ejecutarse automáticamente

---

### 5.3 Probar Pipeline MASTER

```bash
# Merge a master
git checkout master
git merge staging
git push origin master
```

**Ir a Jenkins** → `user-service-master-pipeline` → Debería ejecutarse automáticamente

**Verificar**: Se debe generar un archivo en `release-notes/user-service-v1.0.0.md`

---

## 📊 Checklist de Verificación

| # | Tarea | Comando de Verificación | Estado |
|---|-------|-------------------------|--------|
| 1 | GCR configurado | `gcloud artifacts repositories list` | ❌ |
| 2 | Jenkinsfiles actualizados | Revisar archivos | ❌ |
| 3 | Minikube instalado | `minikube version` | ❌ |
| 4 | Minikube corriendo | `minikube status` | ❌ |
| 5 | Pipelines DEV creados | Revisar Jenkins | ❌ |
| 6 | Pipelines STAGING creados | Revisar Jenkins | ❌ |
| 7 | Pipelines MASTER creados | Revisar Jenkins | ❌ |
| 8 | Pipeline DEV funciona | Ejecutar y verificar | ❌ |
| 9 | Pipeline STAGING funciona | Ejecutar y verificar | ❌ |
| 10 | Pipeline MASTER funciona | Ejecutar y verificar | ❌ |

---

## 🚨 Troubleshooting

### Error: "Cannot push to registry"

```bash
# Re-autenticar con GCR
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

# Verificar permisos
gcloud projects get-iam-policy ecommerce-microservices-476519
```

### Error: "Minikube not starting"

```powershell
# Limpiar y reiniciar
minikube delete
minikube start --driver=docker --cpus=4 --memory=8192
```

### Error: "Jenkins cannot access GCR"

1. Verificar que `jenkins-gcp-key.json` existe
2. Verificar credenciales en Jenkins
3. Verificar permisos del service account

---

## 📝 Notas Importantes

1. **GCR es de pago**: Verifica que tienes créditos en GCP
2. **Minikube consume recursos**: Asegúrate de tener al menos 8GB RAM disponibles
3. **Jenkins necesita acceso**: El service account debe tener permisos de `Artifact Registry Writer`

---

## ✅ Próximo Paso

**Ejecuta ahora**:

```powershell
.\scripts\update-jenkinsfiles-registry.ps1
```

Luego avísame para continuar con el siguiente paso.

---

*Última actualización: 30 de Octubre, 2025*
