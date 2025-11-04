# ✅ Pipeline MASTER/PRODUCTION - Configuración Completa

## 🎯 Resumen

Se han creado los Jenkinsfiles para la rama **master** que gestionan los despliegues a **producción en GKE**.

---

## 📋 Servicios Configurados

| Servicio | Puerto | Jenkinsfile | Namespace | Réplicas |
|----------|--------|-------------|-----------|----------|
| user-service | 8700 | ✅ Creado | ecommerce-prod | 3 |
| order-service | 8300 | ✅ Creado | ecommerce-prod | 3 |
| payment-service | 8400 | ✅ Creado | ecommerce-prod | 3 |
| product-service | 8500 | ✅ Creado | ecommerce-prod | 3 |
| shipping-service | 8600 | ✅ Creado | ecommerce-prod | 3 |
| favourite-service | 8800 | ✅ Creado | ecommerce-prod | 3 |

---

## 🔄 Stages del Pipeline MASTER

### 1. Checkout
- Clona el código del repositorio
- Branch: master

### 2. Pull Image from Staging
- Obtiene la imagen validada de staging
- Tag: `staging-latest` o `staging-BUILD_NUMBER`

### 3. Semantic Versioning
- Aplica versionado semántico (SemVer)
- Etiquetas creadas:
  - `v1.0.0` (versión específica)
  - `prod-latest` (última versión en prod)
  - `prod-BUILD_NUMBER` (build específico)

### 4. Deploy to GKE Production
- Despliega en namespace `ecommerce-prod`
- 3 réplicas por servicio (alta disponibilidad)
- Resource limits configurados:
  - Memory: 256Mi-512Mi
  - CPU: 250m-500m

### 5. Wait for Rollout
- Espera hasta 10 minutos por el rollout completo
- Verifica que todos los pods estén listos

### 6. Smoke Tests
- Health check del servicio
- Verificación de endpoints API
- Validación de versión
- Usa LoadBalancer IP o port-forward como fallback

### 7. Verify Production
- Verifica estado de pods
- Confirma que todos los pods estén Running
- Valida deployment exitoso

### 8. Generate Release Notes
- Crea documento markdown con detalles del release
- Incluye:
  - Información de versión
  - Detalles de deployment
  - Estado de verificación
  - Endpoints del servicio
- Archiva en Jenkins como artifact

### 9. Create Git Tag
- Crea tag en Git: `SERVICE_NAME-vVERSION`
- Ejemplo: `user-service-v1.0.0`

---

## 🎛️ Parámetros del Pipeline

| Parámetro | Descripción | Default |
|-----------|-------------|---------|
| `STAGING_BUILD_NUMBER` | Build de staging a promover | `latest` |
| `VERSION` | Versión semántica (SemVer) | `1.0.0` |
| `SKIP_SMOKE_TESTS` | Saltar smoke tests | `false` |

---

## 🚀 Cómo Ejecutar un Release

### Paso 1: Verificar que Staging esté OK
```bash
# Ver último build exitoso de staging
kubectl get pods -n ecommerce-staging
```

### Paso 2: Ejecutar Pipeline de Master
1. Ir a Jenkins → `[service-name]-pipeline` → `master`
2. Click en "Build with Parameters"
3. Configurar:
   - `STAGING_BUILD_NUMBER`: Número del build de staging (o `latest`)
   - `VERSION`: Versión del release (ej: `1.0.0`, `1.1.0`, `2.0.0`)
   - `SKIP_SMOKE_TESTS`: `false`
4. Click "Build"

### Paso 3: Verificar Release
```bash
# Ver pods en producción
kubectl get pods -n ecommerce-prod

# Ver servicios
kubectl get svc -n ecommerce-prod

# Ver versión desplegada
kubectl get deployment user-service -n ecommerce-prod -o jsonpath='{.spec.template.spec.containers[0].image}'
```

---

## 📊 Versionado Semántico (SemVer)

Sigue el estándar **MAJOR.MINOR.PATCH**:

### MAJOR (1.x.x → 2.x.x)
- Cambios incompatibles en la API
- Refactorización completa
- Cambios de arquitectura

### MINOR (1.0.x → 1.1.x)
- Nuevas funcionalidades
- Cambios compatibles hacia atrás
- Mejoras significativas

### PATCH (1.0.0 → 1.0.1)
- Bug fixes
- Parches de seguridad
- Mejoras menores

**Ejemplos:**
- Primera versión: `1.0.0`
- Nueva feature: `1.1.0`
- Bug fix: `1.0.1`
- Breaking change: `2.0.0`

---

## 🔥 Smoke Tests Implementados

Los smoke tests validan que el servicio esté operativo en producción:

1. **Health Check**
   ```bash
   curl http://SERVICE_URL/actuator/health
   ```

2. **API Endpoint**
   ```bash
   curl http://SERVICE_URL/api/SERVICE_NAME
   ```

3. **Version Info**
   ```bash
   curl http://SERVICE_URL/actuator/info
   ```

**Criterio de éxito**: Al menos 1 de los 3 tests debe pasar

---

## 📝 Release Notes Generadas

Cada release genera un documento markdown con:

- Información de versión y build
- Detalles del deployment
- Estado de verificación
- Endpoints del servicio
- Cambios incluidos

**Ubicación**: `releases/release-vVERSION-SERVICE_NAME.md`

**Ejemplo**: `releases/release-v1.0.0-user-service.md`

---

## 🏗️ Arquitectura de Producción

```
┌─────────────────────────────────────────────┐
│         GKE Production Cluster              │
│                                             │
│  Namespace: ecommerce-prod                  │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  user-service (3 replicas)          │   │
│  │  Image: v1.0.0                      │   │
│  │  LoadBalancer: External IP          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  order-service (3 replicas)         │   │
│  │  Image: v1.0.0                      │   │
│  │  LoadBalancer: External IP          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ... (otros servicios)                      │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🔐 Consideraciones de Seguridad

### Resource Limits
Todos los servicios tienen límites configurados:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Alta Disponibilidad
- 3 réplicas por servicio
- Distribución automática en nodos
- Rolling updates sin downtime

### Monitoreo
- Health checks configurados
- Smoke tests automáticos
- Verificación post-deployment

---

## 📊 Flujo Completo: Dev → Staging → Production

```
┌──────────┐     ┌──────────┐     ┌──────────────┐
│   DEV    │────▶│ STAGING  │────▶│  PRODUCTION  │
│          │     │          │     │              │
│ Build    │     │ E2E      │     │ Smoke Tests  │
│ Test     │     │ Perf     │     │ Versioning   │
│ Coverage │     │ Validate │     │ Release      │
└──────────┘     └──────────┘     └──────────────┘
   Minikube        GKE Staging      GKE Production
   dev-latest      staging-latest   v1.0.0
```

---

## ✅ Checklist de Release

Antes de hacer un release a producción:

- [ ] Todos los tests de DEV pasaron
- [ ] Build de DEV exitoso
- [ ] Imagen promovida a STAGING
- [ ] Pruebas E2E de STAGING pasaron
- [ ] Pruebas de Performance de STAGING pasaron
- [ ] Smoke tests de STAGING OK
- [ ] Versión semántica definida
- [ ] Release notes preparadas
- [ ] Equipo notificado del release

---

## 🎯 Próximos Pasos

### 1. Crear Namespace de Producción
```bash
kubectl create namespace ecommerce-prod
```

### 2. Configurar Pipelines en Jenkins
- Crear multibranch pipeline para cada servicio
- Configurar branch `master` para usar `Jenkinsfile.master`

### 3. Ejecutar Primer Release
```bash
# Ejemplo: user-service v1.0.0
Jenkins → user-service-pipeline → master → Build with Parameters
- STAGING_BUILD_NUMBER: latest
- VERSION: 1.0.0
- SKIP_SMOKE_TESTS: false
```

### 4. Verificar Producción
```bash
kubectl get all -n ecommerce-prod
kubectl get svc -n ecommerce-prod
```

---

## 📚 Documentos Relacionados

- `INFORME_PRUEBAS_COMPLETO.md` - Resumen de pruebas en staging
- `GUIA_VER_REPORTES.md` - Cómo ver reportes de pruebas
- `JENKINS_MULTI_ENVIRONMENT_SETUP.md` - Configuración multi-ambiente
- `user-service/Jenkinsfile.master` - Template de referencia

---

**Estado**: ✅ Configuración completa  
**Ambiente**: GKE Production  
**Namespace**: ecommerce-prod  
**Versionado**: Semantic Versioning habilitado  
**Smoke Tests**: Implementados  
**Release Notes**: Automáticas
