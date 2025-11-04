# 🚀 Configuración de Pipelines Multi-Ambiente

## 📋 Resumen

Este proyecto ahora tiene **3 pipelines por microservicio**, uno para cada ambiente:

- **DEV** (rama `dev`) → Minikube Local
- **STAGING** (rama `staging`) → GKE Cloud
- **MASTER** (rama `master`) → GKE Production

---

## 📁 Estructura de Archivos

```
user-service/
├── Jenkinsfile.dev       ← Pipeline para rama 'dev'
├── Jenkinsfile.staging   ← Pipeline para rama 'staging'
├── Jenkinsfile.master    ← Pipeline para rama 'master'
└── src/

product-service/
├── Jenkinsfile.dev
├── Jenkinsfile.staging
├── Jenkinsfile.master
└── src/

... (mismo para los otros 4 servicios)
```

---

## 🎯 Estrategia por Ambiente

### 📘 **DEV Environment** - Desarrollo Local

**Rama**: `dev`  
**Ambiente**: Minikube (Local)  
**Namespace**: `ecommerce-dev`

#### Stages:
1. ✅ Checkout
2. ✅ Build Maven
3. ✅ Unit Tests (48 pruebas)
4. ✅ Integration Tests (12 pruebas)
5. ✅ Build Docker Image
6. ✅ Tag: `user-service:dev-${BUILD_NUMBER}`
7. ✅ Push to Registry
8. ✅ Deploy to Minikube
9. ✅ Verify Deployment

**Objetivo**: Validar que el código compila y funciona localmente

---

### 📗 **STAGING Environment** - Pre-Producción

**Rama**: `staging`  
**Ambiente**: GKE (Google Cloud)  
**Namespace**: `ecommerce-staging`

#### Stages:
1. ✅ Checkout
2. ✅ Pull Image from Dev (reutiliza imagen)
3. ✅ Retag: `user-service:staging-${BUILD_NUMBER}`
4. ✅ Deploy to GKE Staging
5. ✅ Wait for Rollout
6. ✅ E2E Tests (23 pruebas)
7. ✅ Performance Tests (Locust)
8. ✅ Generate Test Report
9. ✅ Verify Health Checks

**Objetivo**: Validar exhaustivamente en ambiente real de nube

---

### 📕 **MASTER Environment** - Producción

**Rama**: `master`  
**Ambiente**: GKE (Google Cloud)  
**Namespace**: `ecommerce-prod`

#### Stages:
1. ✅ Checkout
2. ✅ Pull Image from Staging (reutiliza imagen validada)
3. ✅ Semantic Versioning (v1.0.0)
4. ✅ Retag: `user-service:v1.0.0` y `latest`
5. ✅ System Tests (Smoke tests)
6. ✅ Deploy to GKE Production
7. ✅ Verify Production
8. ✅ **Generate Release Notes**

**Objetivo**: Desplegar a producción con documentación automática

---

## 🔧 Configuración en Jenkins

### Paso 1: Crear Pipelines para DEV

Para cada microservicio, crea un **Multibranch Pipeline**:

1. **Jenkins** → New Item
2. **Nombre**: `user-service-dev-pipeline`
3. **Tipo**: Multibranch Pipeline
4. **Configurar**:
   - **Branch Sources**: Git
   - **Repository**: `https://github.com/tu-usuario/tu-repo.git`
   - **Credentials**: (tus credenciales)
   - **Behaviors**: 
     - Discover branches
     - Filter by name: `dev`
   - **Build Configuration**:
     - Mode: `by Jenkinsfile`
     - Script Path: `user-service/Jenkinsfile.dev`
5. **Save**

Repetir para:
- `product-service-dev-pipeline` → `product-service/Jenkinsfile.dev`
- `order-service-dev-pipeline` → `order-service/Jenkinsfile.dev`
- `payment-service-dev-pipeline` → `payment-service/Jenkinsfile.dev`
- `favourite-service-dev-pipeline` → `favourite-service/Jenkinsfile.dev`
- `shipping-service-dev-pipeline` → `shipping-service/Jenkinsfile.dev`

---

### Paso 2: Crear Pipelines para STAGING

1. **Jenkins** → New Item
2. **Nombre**: `user-service-staging-pipeline`
3. **Tipo**: Multibranch Pipeline
4. **Configurar**:
   - **Branch Sources**: Git
   - **Repository**: (mismo)
   - **Behaviors**: 
     - Discover branches
     - Filter by name: `staging`
   - **Build Configuration**:
     - Script Path: `user-service/Jenkinsfile.staging`
5. **Save**

Repetir para los otros 5 servicios.

---

### Paso 3: Crear Pipelines para MASTER

1. **Jenkins** → New Item
2. **Nombre**: `user-service-master-pipeline`
3. **Tipo**: Multibranch Pipeline
4. **Configurar**:
   - **Branch Sources**: Git
   - **Repository**: (mismo)
   - **Behaviors**: 
     - Discover branches
     - Filter by name: `master`
   - **Build Configuration**:
     - Script Path: `user-service/Jenkinsfile.master`
5. **Save**

Repetir para los otros 5 servicios.

---

## 🔄 Flujo de Trabajo Completo

### 1. Desarrollo en DEV

```bash
# Developer hace cambios
git checkout dev
git add .
git commit -m "feat: nueva funcionalidad"
git push origin dev
```

**Jenkins ejecuta automáticamente**:
- ✅ Build + Docker
- ✅ Unit Tests (48)
- ✅ Integration Tests (12)
- ✅ Deploy Minikube

**Resultado**: Imagen `user-service:dev-123` en registry

---

### 2. Promoción a STAGING

```bash
# Merge de dev a staging
git checkout staging
git merge dev
git push origin staging
```

**Jenkins ejecuta automáticamente**:
- ✅ Pull imagen de dev
- ✅ Deploy GKE Staging
- ✅ E2E Tests (23)
- ✅ Performance Tests (Locust)

**Resultado**: Imagen `user-service:staging-456` validada

---

### 3. Release a PRODUCTION

```bash
# Merge de staging a master
git checkout master
git merge staging
git push origin master
```

**Jenkins ejecuta automáticamente**:
- ✅ Pull imagen de staging
- ✅ Versioning (v1.0.0)
- ✅ Smoke Tests
- ✅ Deploy GKE Production
- ✅ **Generate Release Notes**

**Resultado**: 
- Imagen `user-service:v1.0.0` en producción
- Release Notes generadas automáticamente

---

## 📊 Tabla Comparativa

| Aspecto | DEV | STAGING | MASTER |
|---------|-----|---------|--------|
| **Rama** | `dev` | `staging` | `master` |
| **Ambiente** | Minikube | GKE | GKE |
| **Namespace** | `ecommerce-dev` | `ecommerce-staging` | `ecommerce-prod` |
| **Build Maven** | ✅ | ❌ | ❌ |
| **Build Docker** | ✅ | ❌ | ❌ |
| **Reutiliza Imagen** | ❌ | ✅ (dev) | ✅ (staging) |
| **Unit Tests** | ✅ 48 | ❌ | ❌ |
| **Integration Tests** | ✅ 12 | ❌ | ❌ |
| **E2E Tests** | ❌ | ✅ 23 | ❌ |
| **Performance Tests** | ❌ | ✅ Locust | ❌ |
| **System Tests** | ❌ | ❌ | ✅ Smoke |
| **Release Notes** | ❌ | ❌ | ✅ |
| **Replicas** | 1 | 2 | 3 |

---

## 🛠️ Prerequisitos

### Para DEV (Minikube)

```bash
# Instalar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Iniciar Minikube
minikube start --driver=docker

# Verificar
kubectl get nodes
```

### Para STAGING y MASTER (GKE)

Ya configurado en tu proyecto:
- ✅ GKE Cluster activo
- ✅ kubectl configurado
- ✅ gcloud auth configurado

### Docker Registry

**Opción 1: Registry Local** (para pruebas)
```bash
docker run -d -p 5000:5000 --name registry registry:2
```

**Opción 2: Google Container Registry**
```bash
# Cambiar en los Jenkinsfiles:
DOCKER_REGISTRY = 'gcr.io/tu-proyecto-gcp'
```

**Opción 3: Docker Hub**
```bash
# Cambiar en los Jenkinsfiles:
DOCKER_REGISTRY = 'docker.io/tu-usuario'
```

---

## 📝 Parámetros de los Pipelines

### DEV Pipeline
- `SKIP_TESTS`: Saltar pruebas (default: false)
- `SKIP_DEPLOY`: Saltar deploy en Minikube (default: false)

### STAGING Pipeline
- `DEV_BUILD_NUMBER`: Número de build de DEV a desplegar (default: latest)
- `SKIP_E2E_TESTS`: Saltar pruebas E2E (default: false)
- `SKIP_PERFORMANCE_TESTS`: Saltar pruebas de rendimiento (default: false)

### MASTER Pipeline
- `STAGING_BUILD_NUMBER`: Número de build de STAGING a promover (default: latest)
- `VERSION`: Versión semántica (ej: 1.0.0). Si vacío, auto-incrementa
- `SKIP_SMOKE_TESTS`: Saltar smoke tests (default: false)

---

## 🎯 Ejemplo de Uso

### Escenario 1: Desarrollo Normal

```bash
# 1. Desarrollar en dev
git checkout dev
# ... hacer cambios ...
git push origin dev
# → Jenkins ejecuta dev pipeline

# 2. Validar en staging
git checkout staging
git merge dev
git push origin staging
# → Jenkins ejecuta staging pipeline

# 3. Release a producción
git checkout master
git merge staging
git push origin master
# → Jenkins ejecuta master pipeline
# → Se genera Release Notes automáticamente
```

### Escenario 2: Hotfix en Producción

```bash
# 1. Crear branch de hotfix desde master
git checkout master
git checkout -b hotfix/critical-bug
# ... fix bug ...
git push origin hotfix/critical-bug

# 2. Merge a master
git checkout master
git merge hotfix/critical-bug
git push origin master
# → Jenkins despliega a producción

# 3. Backport a staging y dev
git checkout staging
git merge master
git checkout dev
git merge staging
```

---

## 📋 Release Notes Automáticas

Las Release Notes se generan automáticamente en el pipeline de MASTER e incluyen:

- 📦 Información del release (versión, fecha, build)
- 🐳 Imágenes Docker generadas
- 📊 Estado del despliegue
- 🔄 Commits incluidos
- ✅ Validaciones realizadas
- 🎯 Estado de ambientes
- 👥 Información del equipo

**Ubicación**: `release-notes/user-service-v1.0.0.md`

**Ejemplo**:
```markdown
# Release Notes - user-service v1.0.0

## 📦 Información del Release
- Versión: v1.0.0
- Fecha: 2025-10-30 15:30:00
- Build: #123

## 🐳 Imagen Docker
user-service:v1.0.0
user-service:latest

## ✅ Validaciones
- ✅ 48 pruebas unitarias
- ✅ 12 pruebas de integración
- ✅ 23 pruebas E2E
- ✅ Pruebas de rendimiento
```

---

## ✅ Cumplimiento de Requisitos del Taller

| Actividad | Requisito | Implementación | Estado |
|-----------|-----------|----------------|--------|
| **2** | Pipelines construcción (dev) | Jenkinsfile.dev | ✅ |
| **3** | Pruebas unitarias (≥5) | 48 pruebas en DEV | ✅ |
| **3** | Pruebas integración (≥5) | 12 pruebas en DEV | ✅ |
| **3** | Pruebas E2E (≥5) | 23 pruebas en STAGING | ✅ |
| **3** | Pruebas rendimiento (Locust) | Locust en STAGING | ✅ |
| **4** | Pipelines con pruebas en K8s (stage) | Jenkinsfile.staging | ✅ |
| **5** | Pipeline despliegue + Release Notes | Jenkinsfile.master | ✅ |

---

## 🚨 Troubleshooting

### Error: "Cannot connect to Minikube"
```bash
minikube status
minikube start
```

### Error: "Image not found in registry"
```bash
# Verificar que el pipeline de DEV se ejecutó correctamente
docker images | grep user-service
```

### Error: "kubectl: command not found"
```bash
# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

## 📚 Próximos Pasos

1. ✅ Crear los 3 Jenkinsfiles para los otros 5 microservicios
2. ✅ Configurar los 18 pipelines en Jenkins (6 servicios × 3 ambientes)
3. ✅ Configurar Docker Registry (local, GCR o Docker Hub)
4. ✅ Instalar Minikube para ambiente DEV
5. ✅ Probar el flujo completo: dev → staging → master

---

**¡Pipelines multi-ambiente listos para el taller!** 🎉

*Generado automáticamente - 30 de Octubre, 2025*
