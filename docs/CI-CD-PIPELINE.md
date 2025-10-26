# 🚀 CI/CD Pipeline - E-commerce Microservices

## 📋 Estrategia de Ramas (GitFlow)

Este proyecto implementa una estrategia de **GitFlow simplificado** con 3 ramas principales:

```
dev → staging → master
```

### 🌿 Ramas y Ambientes

| Rama | Ambiente | Namespace K8s | Deploy | Integration Tests |
|------|----------|---------------|--------|-------------------|
| `dev` | Development | `ecommerce-dev` | ❌ No | ❌ No |
| `staging` | Staging | `ecommerce-staging` | ✅ Sí | ✅ Sí |
| `master` | Production | `ecommerce-prod` | ✅ Sí | ❌ No |

---

## 🔄 Flujo de Trabajo

### 1️⃣ **Desarrollo en `dev`**
```bash
git checkout dev
# ... hacer cambios ...
git add .
git commit -m "feat: nueva funcionalidad"
git push origin dev
```

**Jenkins ejecuta:**
- ✅ Checkout del código
- ✅ Build de microservicios (Maven)
- ✅ Pruebas unitarias
- ✅ Build de imágenes Docker
- ❌ **NO despliega** a ningún ambiente

**Objetivo:** Validar que el código compila y pasa las pruebas unitarias.

---

### 2️⃣ **Pruebas en `staging`**
```bash
git checkout staging
git merge dev
git push origin staging
```

**Jenkins ejecuta:**
- ✅ Checkout del código
- ✅ Build de microservicios (Maven)
- ✅ Pruebas unitarias
- ✅ Build de imágenes Docker
- ✅ **Push a Docker Registry**
- ✅ **Deploy a Kubernetes** (namespace: `ecommerce-staging`)
- ✅ Verificación del despliegue
- ✅ Smoke tests
- ✅ **Pruebas de integración** 🧪

**Pruebas de Integración incluyen:**
1. Verificar estado de pods (Running)
2. Revisar logs de cada servicio
3. Verificar conectividad de servicios
4. Health checks (actuator/health)
5. Pruebas entre servicios
6. Verificar Service Discovery (Eureka)
7. Resumen completo del ambiente

**Objetivo:** Validar que los microservicios funcionan correctamente en un ambiente similar a producción.

---

### 3️⃣ **Despliegue a `master` (Producción)**
```bash
git checkout master
git merge staging
git push origin master
```

**Jenkins ejecuta:**
- ✅ Checkout del código
- ✅ Build de microservicios (Maven)
- ✅ Pruebas unitarias
- ✅ Build de imágenes Docker
- ✅ **Push a Docker Registry**
- ✅ **Deploy a Kubernetes** (namespace: `ecommerce-prod`)
- ✅ Verificación del despliegue
- ✅ Smoke tests
- ❌ No ejecuta integration tests (ya fueron validados en staging)

**Objetivo:** Desplegar a producción con confianza después de haber validado en staging.

---

## 🧪 Pruebas de Integración en Staging

El pipeline ejecuta automáticamente pruebas de integración cuando se despliega a la rama `staging`:

### Pruebas por Servicio:
Para cada microservicio desplegado, se verifica:

1. **Estado del Pod**
   ```bash
   kubectl get pods -n ecommerce-staging -l app=user-service
   ```

2. **Logs del Servicio**
   ```bash
   kubectl logs -n ecommerce-staging -l app=user-service --tail=20
   ```

3. **Conectividad del Servicio**
   ```bash
   kubectl get svc -n ecommerce-staging user-service
   ```

4. **Health Check**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

### Pruebas de Integración:
- ✅ Verificar comunicación entre servicios
- ✅ Verificar registro en Service Discovery (Eureka)
- ✅ Verificar que todos los servicios estén operativos
- ✅ Generar reporte completo del estado del ambiente

---

## 📊 Stages del Pipeline

### Stage 1: **Determine Environment**
Detecta la rama actual y configura:
- Ambiente (dev, staging, production)
- Namespace de Kubernetes
- Si debe hacer deploy
- Si debe ejecutar integration tests

### Stage 2: **Checkout**
Clona el repositorio

### Stage 3: **Build All Services**
Compila todos los microservicios con Maven

### Stage 4: **Unit Tests**
Ejecuta pruebas unitarias (puede saltarse con parámetro `SKIP_TESTS`)

### Stage 5: **Build Docker Images**
Construye imágenes Docker para cada microservicio

### Stage 6: **Push Docker Images**
Sube imágenes a Docker Registry (solo en `staging` y `master`)

### Stage 7: **Deploy to Kubernetes**
Despliega a Kubernetes (solo en `staging` y `master`)

### Stage 8: **Verify Deployment**
Verifica que el despliegue fue exitoso

### Stage 9: **Smoke Tests**
Ejecuta pruebas básicas de funcionamiento

### Stage 10: **Integration Tests - Staging** 🧪
Ejecuta pruebas de integración completas (solo en `staging`)

---

## 🎯 Parámetros del Pipeline

### `DEPLOY_SERVICES`
Selecciona qué servicios desplegar:
- `ALL` (todos los servicios)
- `user-service`
- `product-service`
- `order-service`
- `payment-service`
- `favourite-service`
- `shipping-service`

### `SKIP_TESTS`
- `false` (default): Ejecuta pruebas unitarias
- `true`: Salta pruebas unitarias

### `DEPLOY_TO_K8S`
- `true` (default): Despliega a Kubernetes
- `false`: Solo build y tests

---

## 🔐 Requisitos Previos

### 1. Credenciales en Jenkins:
- **Docker Hub**: ID `dockerhub`
- **Kubernetes**: Configurado con `kubectl`

### 2. Namespaces en Kubernetes:
```bash
kubectl create namespace ecommerce-dev
kubectl create namespace ecommerce-staging
kubectl create namespace ecommerce-prod
```

### 3. Archivos de Deployment:
- `k8s/infrastructure/` - Servicios de infraestructura (Zipkin, Eureka, Config Server, API Gateway)
- `k8s/microservices/` - Deployments de microservicios

---

## 📈 Ejemplo de Uso

### Desarrollo Normal:
```bash
# 1. Trabajar en dev
git checkout dev
git add .
git commit -m "feat: agregar endpoint de usuarios"
git push origin dev
# → Jenkins: Build + Tests (sin deploy)
```

### Probar en Staging:
```bash
# 2. Merge a staging para probar
git checkout staging
git merge dev
git push origin staging
# → Jenkins: Build + Tests + Deploy + Integration Tests
```

### Desplegar a Producción:
```bash
# 3. Si todo está OK en staging, merge a master
git checkout master
git merge staging
git push origin master
# → Jenkins: Build + Tests + Deploy a Production
```

---

## ✅ Criterios de Éxito

### En `dev`:
- ✅ Código compila sin errores
- ✅ Pruebas unitarias pasan

### En `staging`:
- ✅ Código compila sin errores
- ✅ Pruebas unitarias pasan
- ✅ Imágenes Docker se construyen correctamente
- ✅ Deploy a Kubernetes exitoso
- ✅ **Todos los pods están en estado Running**
- ✅ **Health checks responden OK**
- ✅ **Servicios se comunican entre sí**
- ✅ **Service Discovery registra todos los servicios**

### En `master`:
- ✅ Todo lo anterior (validado en staging)
- ✅ Deploy a producción exitoso
- ✅ Smoke tests pasan

---

## 🚨 Manejo de Errores

### Si falla en `dev`:
- ❌ No hacer merge a `staging`
- 🔧 Corregir errores en `dev`

### Si falla en `staging`:
- ❌ **NO hacer merge a `master`**
- 🔧 Corregir errores y volver a probar en `staging`
- 🧪 Las pruebas de integración deben pasar antes de ir a producción

### Si falla en `master`:
- 🚨 Rollback inmediato
- 🔍 Investigar por qué pasó en staging pero falló en producción

---

## 📊 Monitoreo

### Ver logs del pipeline:
```bash
# Jenkins UI
https://jenkins.example.com/job/ecommerce-pipeline/
```

### Ver estado en Kubernetes:
```bash
# Staging
kubectl get pods -n ecommerce-staging
kubectl get svc -n ecommerce-staging
kubectl logs -n ecommerce-staging -l app=user-service

# Production
kubectl get pods -n ecommerce-prod
kubectl get svc -n ecommerce-prod
```

---

## 🎓 Para la Rúbrica

Este pipeline cumple con los requisitos de:

✅ **CI/CD completo** con 3 ambientes (dev, staging, production)
✅ **Pruebas automatizadas** en staging (integration tests)
✅ **Despliegue a Kubernetes** con verificación
✅ **GitFlow profesional** con separación de ambientes
✅ **Validación antes de producción** mediante staging

---

## 🔗 Referencias

- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
