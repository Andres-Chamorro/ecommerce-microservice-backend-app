# 📕 Instrucciones para Ejecutar Pipeline de MASTER (Producción)

## ✅ Estado Actual

Los **Jenkinsfiles principales** de todos los servicios ahora están configurados con el **pipeline de PRODUCCIÓN (MASTER)**.

### Archivos Actualizados
- ✅ `user-service/Jenkinsfile`
- ✅ `order-service/Jenkinsfile`
- ✅ `payment-service/Jenkinsfile`
- ✅ `product-service/Jenkinsfile`
- ✅ `shipping-service/Jenkinsfile`
- ✅ `favourite-service/Jenkinsfile`

---

## 🚀 Cómo Ejecutar el Pipeline de MASTER en Jenkins

### Paso 1: Acceder a Jenkins

1. Abrir navegador en: `http://localhost:8080`
2. Iniciar sesión con tus credenciales

### Paso 2: Seleccionar el Servicio

Ir a uno de los jobs configurados para la rama **master**:
- `user-service-master`
- `order-service-master`
- `payment-service-master`
- `product-service-master`
- `shipping-service-master`
- `favourite-service-master`

### Paso 3: Configurar Parámetros del Build

Click en **"Build with Parameters"** y configurar:

#### Parámetros Requeridos:

1. **STAGING_BUILD_NUMBER**
   - Valor: Número del build exitoso de STAGING que quieres promover
   - Ejemplo: `45` (si el build de staging fue #45)
   - Default: `latest` (usa el último build de staging)

2. **VERSION**
   - Valor: Versión semántica para el release
   - Formato: `MAJOR.MINOR.PATCH`
   - Ejemplos:
     - `1.0.0` - Primera versión de producción
     - `1.0.1` - Bug fix
     - `1.1.0` - Nueva funcionalidad
     - `2.0.0` - Breaking change

3. **SKIP_SMOKE_TESTS** (opcional)
   - Valor: `false` (recomendado)
   - Descripción: Si es `true`, salta los smoke tests en producción

### Paso 4: Ejecutar el Build

Click en **"Build"** para iniciar el pipeline de producción.

---

## 📊 Stages del Pipeline de MASTER

El pipeline ejecutará los siguientes stages:

### 1. Checkout ✅
- Clona el repositorio
- Obtiene información del commit para release notes

### 2. Pull Image from Staging ✅
- Descarga la imagen validada desde STAGING
- Tag: `staging-{BUILD_NUMBER}` o `staging-latest`
- Verifica integridad de la imagen

### 3. Semantic Versioning ✅
- Aplica versionado semántico
- Crea tags:
  - `v{VERSION}` (ej: v1.0.0)
  - `prod-latest`
  - `prod-{BUILD_NUMBER}`
- Sube imágenes versionadas al registry

### 4. Deploy to GKE Production ✅
- Despliega en namespace `ecommerce-prod`
- Crea/actualiza deployment con 3 réplicas
- Configura LoadBalancer
- Aplica labels de producción

### 5. Wait for Rollout ✅
- Espera hasta 10 minutos por rollout completo
- Verifica que todos los pods estén Running
- Muestra estado del deployment

### 6. Smoke Tests ✅
- Health Check: `/actuator/health`
- API Endpoint: `/api/{resource}`
- Version Check: `/actuator/info`
- Usa LoadBalancer IP o port-forward

### 7. Verify Production ✅
- Verifica estado de pods
- Verifica estado de servicios
- Verifica estado de deployment
- Confirma que todos los pods están Running

### 8. Generate Release Notes ✅
- Genera documentación automática del release
- Incluye:
  - Información de versión y build
  - Detalles del deployment
  - Cambios incluidos
  - Quality gates pasados
  - Instrucciones de verificación
  - Plan de rollback
- Archiva como artifact en Jenkins

### 9. Create Git Tag ✅
- Crea tag anotado en Git
- Formato: `{SERVICE_NAME}-v{VERSION}`
- Incluye metadata del release

---

## 📝 Ejemplo de Ejecución

### Escenario: Promover user-service a producción

1. **Build de STAGING exitoso**: #45
2. **Nueva versión**: v1.2.0 (nueva funcionalidad)

**Parámetros:**
```
STAGING_BUILD_NUMBER: 45
VERSION: 1.2.0
SKIP_SMOKE_TESTS: false
```

**Resultado esperado:**
- Imagen promovida: `user-service:staging-45` → `user-service:v1.2.0`
- Deployment en `ecommerce-prod` con 3 réplicas
- Smoke tests ejecutados y pasados
- Release notes generadas
- Git tag creado: `user-service-v1.2.0`

---

## 🔍 Verificación Post-Deployment

### Verificar en GKE

```bash
# Ver deployments en producción
kubectl get deployments -n ecommerce-prod

# Ver pods en producción
kubectl get pods -n ecommerce-prod

# Ver servicios y IPs externas
kubectl get svc -n ecommerce-prod

# Ver logs de un servicio
kubectl logs -f deployment/user-service -n ecommerce-prod

# Ver eventos recientes
kubectl get events -n ecommerce-prod --sort-by='.lastTimestamp'
```

### Verificar Health Checks

```bash
# Obtener IP externa del servicio
EXTERNAL_IP=$(kubectl get svc user-service -n ecommerce-prod -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Health check
curl http://$EXTERNAL_IP:8700/actuator/health

# API endpoint
curl http://$EXTERNAL_IP:8700/api/users

# Metrics
curl http://$EXTERNAL_IP:8700/actuator/metrics
```

### Verificar en Jenkins

1. Ver logs del build
2. Descargar release notes (artifacts)
3. Verificar que todos los stages pasaron
4. Revisar duración del deployment

---

## 🔄 Plan de Rollback

Si hay problemas en producción, puedes hacer rollback:

### Opción 1: Rollback Automático (Kubernetes)

```bash
# Rollback al deployment anterior
kubectl rollout undo deployment/user-service -n ecommerce-prod

# Ver historial de rollouts
kubectl rollout history deployment/user-service -n ecommerce-prod

# Rollback a versión específica
kubectl rollout undo deployment/user-service --to-revision=2 -n ecommerce-prod
```

### Opción 2: Rollback Manual (Re-deploy versión anterior)

1. En Jenkins, ejecutar nuevo build con parámetros:
   - `STAGING_BUILD_NUMBER`: Build anterior que funcionaba
   - `VERSION`: Versión anterior (ej: 1.1.0)

### Opción 3: Cambiar imagen manualmente

```bash
# Cambiar a versión anterior
kubectl set image deployment/user-service user-service=REGISTRY/user-service:v1.1.0 -n ecommerce-prod

# Verificar rollback
kubectl rollout status deployment/user-service -n ecommerce-prod
```

---

## 📊 Monitoreo Post-Release

### Métricas Clave a Monitorear

1. **Availability**
   - Uptime del servicio
   - Pods en estado Running

2. **Response Time**
   - Latencia de APIs
   - Tiempo de respuesta promedio

3. **Error Rate**
   - Tasa de errores 4xx/5xx
   - Errores de aplicación

4. **Throughput**
   - Requests por segundo
   - Carga del sistema

5. **Resource Usage**
   - CPU utilizado
   - Memoria utilizada

### Comandos de Monitoreo

```bash
# Ver uso de recursos de pods
kubectl top pods -n ecommerce-prod

# Ver logs en tiempo real
kubectl logs -f deployment/user-service -n ecommerce-prod

# Ver descripción completa del deployment
kubectl describe deployment user-service -n ecommerce-prod

# Ver estado de todos los recursos
kubectl get all -n ecommerce-prod
```

---

## 🎯 Flujo Completo de Release

```
1. DEV (rama dev)
   ↓
   Build → Test → Deploy Minikube → Push to Registry
   
2. STAGING (rama staging)
   ↓
   Pull from DEV → Deploy GKE Staging → E2E Tests → Performance Tests
   
3. MASTER (rama master) ← ESTÁS AQUÍ
   ↓
   Pull from STAGING → Semantic Version → Deploy GKE Production → Smoke Tests → Release Notes
```

---

## ✅ Checklist Pre-Release

Antes de ejecutar el pipeline de MASTER, verifica:

- [ ] Build de STAGING exitoso y validado
- [ ] E2E tests pasaron en STAGING
- [ ] Performance tests pasaron en STAGING
- [ ] Versión semántica definida correctamente
- [ ] Namespace `ecommerce-prod` existe en GKE
- [ ] Credenciales GCP configuradas en Jenkins
- [ ] kubectl configurado para acceder a GKE
- [ ] Equipo notificado del release

---

## 📚 Documentación Adicional

- **Pipeline DEV**: Ver `INSTRUCCIONES_EJECUTAR_PIPELINE.md`
- **Pipeline STAGING**: Ver `INSTRUCCIONES_EJECUTAR_STAGING.md`
- **Configuración GKE**: Ver `scripts/setup-jenkins-for-gke.ps1`
- **Release Notes**: Se generan automáticamente en `releases/`

---

## 🆘 Troubleshooting

### Problema: Imagen de staging no encontrada

**Solución:**
- Verificar que el build de STAGING existe
- Verificar tag de imagen en registry
- Usar `STAGING_BUILD_NUMBER: latest` si no estás seguro

### Problema: Deployment falla en GKE

**Solución:**
- Verificar credenciales GCP en Jenkins
- Verificar que kubectl puede acceder al cluster
- Revisar logs: `kubectl logs -f deployment/SERVICE -n ecommerce-prod`

### Problema: Smoke tests fallan

**Solución:**
- Verificar que el servicio está corriendo
- Verificar LoadBalancer IP
- Revisar logs del pod
- Verificar health endpoint manualmente

### Problema: Rollout timeout

**Solución:**
- Verificar recursos del cluster (CPU/memoria)
- Verificar que la imagen existe en registry
- Revisar eventos: `kubectl get events -n ecommerce-prod`
- Aumentar timeout si es necesario

---

## 🎉 ¡Listo para Producción!

Tu pipeline de MASTER está completamente configurado y listo para ejecutar releases de producción con:

- ✅ Versionado semántico automático
- ✅ Deployment en GKE con alta disponibilidad (3 réplicas)
- ✅ Smoke tests automáticos
- ✅ Release notes generadas automáticamente
- ✅ Git tags para trazabilidad
- ✅ Plan de rollback documentado

**¡Buena suerte con tu primer release a producción!** 🚀
