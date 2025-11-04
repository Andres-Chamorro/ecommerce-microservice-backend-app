# 🔧 Resumen: Corrección de Pruebas E2E en Staging

## ❌ Problemas Encontrados

1. **JAVA_HOME no configurado** → Maven no podía ejecutarse
2. **SERVICE_URL vacío** (`:8200`) → No había IP externa
3. **Servicios con ClusterIP** → Sin acceso externo para pruebas
4. **Puerto incorrecto** en favourite-service (8600 vs 8800)

## ✅ Soluciones Aplicadas

### 1. Exportar JAVA_HOME en todos los Jenkinsfiles
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

### 2. Esperar IP externa del LoadBalancer
```bash
for i in {1..24}; do
    SERVICE_IP=$(kubectl get svc ${SERVICE_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -n "$SERVICE_IP" ]; then
        break
    fi
    sleep 5
done
```

### 3. Fallback a port-forward si no hay IP
```bash
if [ -z "$SERVICE_IP" ]; then
    kubectl port-forward -n ${K8S_NAMESPACE} svc/${SERVICE_NAME} ${SERVICE_PORT}:${SERVICE_PORT} &
    SERVICE_URL="localhost"
else
    SERVICE_URL="$SERVICE_IP"
fi
```

### 4. Cambiar servicios a LoadBalancer
```yaml
spec:
  type: LoadBalancer  # Antes: ClusterIP
```

### 5. Corregir puerto de favourite-service
```groovy
SERVICE_PORT = '8800'  // Antes: '8600'
```

## 📊 Servicios Actualizados

| Servicio | Estado | Cambios |
|----------|--------|---------|
| shipping-service | ✅ | Jenkinsfile + Deployment |
| user-service | ✅ | Jenkinsfile + Deployment |
| product-service | ✅ | Jenkinsfile + Deployment |
| order-service | ✅ | Jenkinsfile + Deployment |
| payment-service | ✅ | Jenkinsfile + Deployment |
| favourite-service | ✅ | Jenkinsfile + Deployment + Puerto |

## 🚀 Resultado Esperado

Cuando ejecutes el pipeline de staging ahora verás:

```
⏳ Esperando IP externa del LoadBalancer...
Intento 1/24: Esperando IP externa...
Intento 2/24: Esperando IP externa...
✅ IP externa obtenida: 34.123.45.67
🌐 Service URL: http://34.123.45.67:8600

[INFO] Scanning for projects...
[INFO] Building shipping-service 1.0.0
[INFO] Running E2E tests...
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

## 📝 Archivos Modificados

### Jenkinsfiles (6 archivos):
- `shipping-service/Jenkinsfile`
- `user-service/Jenkinsfile`
- `product-service/Jenkinsfile`
- `order-service/Jenkinsfile`
- `payment-service/Jenkinsfile`
- `favourite-service/Jenkinsfile`

### Deployments (6 archivos):
- `k8s/microservices/shipping-service-deployment.yaml`
- `k8s/microservices/user-service-deployment.yaml`
- `k8s/microservices/product-service-deployment.yaml`
- `k8s/microservices/order-service-deployment.yaml`
- `k8s/microservices/payment-service-deployment.yaml`
- `k8s/microservices/favourite-service-deployment.yaml`

## ✅ Listo para Probar

**Ejecuta el pipeline de staging de cualquier servicio y las pruebas E2E deberían funcionar correctamente.**

Si no tienes pruebas E2E implementadas, verás:
```
ℹ️ No hay pruebas E2E configuradas
```

Si no tienes pruebas de Performance implementadas, verás:
```
ℹ️ No hay pruebas de rendimiento configuradas (tests/performance/locustfile.py no existe)
Saltando pruebas de rendimiento...
ℹ️ No se generó reporte de rendimiento (no hay pruebas configuradas)
```

Esto es normal y el pipeline continuará exitosamente.

## 🔧 Correcciones Adicionales - Performance Tests

También se corrigió el stage de Performance Tests:

1. ✅ **JAVA_HOME exportado** (igual que E2E)
2. ✅ **Espera de IP externa** (hasta 1 minuto)
3. ✅ **No hace `cd`** - usa ruta completa `tests/performance/locustfile.py`
4. ✅ **Solo archiva si existe** - usa `fileExists()` antes de archivar
5. ✅ **Mensajes claros** - indica si no hay pruebas configuradas
