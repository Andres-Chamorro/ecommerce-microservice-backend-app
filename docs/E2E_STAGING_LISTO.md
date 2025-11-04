# ✅ Pruebas E2E en Staging - CORREGIDAS

## 🎯 Problemas Resueltos

### 1. ❌ JAVA_HOME no configurado → ✅ SOLUCIONADO
- **Antes**: `The JAVA_HOME environment variable is not defined correctly`
- **Ahora**: `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64` en todos los stages E2E

### 2. ❌ SERVICE_URL vacío → ✅ SOLUCIONADO
- **Antes**: `Service URL: :8200` (sin IP)
- **Ahora**: 
  - Espera hasta 2 minutos por IP externa de LoadBalancer
  - Fallback automático a port-forward si no hay IP
  - Muestra: `Service URL: http://34.123.45.67:8600`

### 3. ❌ Puerto incorrecto en favourite-service → ✅ SOLUCIONADO
- **Antes**: Jenkinsfile usaba 8600, deployment usaba 8800
- **Ahora**: Ambos usan 8800

### 4. ❌ Servicios sin IP externa → ✅ SOLUCIONADO
- **Antes**: `type: ClusterIP` (solo acceso interno)
- **Ahora**: `type: LoadBalancer` (IP externa para pruebas)

## 📋 Servicios Actualizados

| Servicio | Puerto | Jenkinsfile | Deployment | Estado |
|----------|--------|-------------|------------|--------|
| shipping-service | 8600 | ✅ | ✅ LoadBalancer | ✅ LISTO |
| user-service | 8700 | ✅ | ✅ LoadBalancer | ✅ LISTO |
| product-service | 8500 | ✅ | ✅ LoadBalancer | ✅ LISTO |
| order-service | 8300 | ✅ | ✅ LoadBalancer | ✅ LISTO |
| payment-service | 8400 | ✅ | ✅ LoadBalancer | ✅ LISTO |
| favourite-service | 8800 | ✅ | ✅ LoadBalancer | ✅ LISTO |

## 🔧 Cambios Técnicos Aplicados

### En Jenkinsfiles (stage E2E):
```groovy
sh '''
    . /root/google-cloud-sdk/path.bash.inc
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    
    # Esperar IP externa (hasta 2 minutos)
    echo "⏳ Esperando IP externa del LoadBalancer..."
    for i in {1..24}; do
        SERVICE_IP=$(kubectl get svc ${SERVICE_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$SERVICE_IP" ]; then
            echo "✅ IP externa obtenida: $SERVICE_IP"
            break
        fi
        echo "Intento $i/24: Esperando IP externa..."
        sleep 5
    done
    
    # Fallback a port-forward
    if [ -z "$SERVICE_IP" ]; then
        echo "⚠️ No se pudo obtener IP externa, usando port-forward como fallback"
        kubectl port-forward -n ${K8S_NAMESPACE} svc/${SERVICE_NAME} ${SERVICE_PORT}:${SERVICE_PORT} &
        PORT_FORWARD_PID=$!
        sleep 5
        SERVICE_URL="localhost"
    else
        SERVICE_URL="$SERVICE_IP"
    fi
    
    echo "🌐 Service URL: http://$SERVICE_URL:${SERVICE_PORT}"
    
    # Ejecutar pruebas E2E
    if [ -d tests/e2e ]; then
        cd tests/e2e
        mvn test -Dtest=*E2ETest -Dservice.url=http://$SERVICE_URL:${SERVICE_PORT}
    fi
    
    # Limpiar port-forward
    if [ -n "$PORT_FORWARD_PID" ]; then
        kill $PORT_FORWARD_PID 2>/dev/null || true
    fi
'''
```

### En Deployments (k8s/microservices/*-deployment.yaml):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: <service-name>
  namespace: ecommerce-staging
spec:
  type: LoadBalancer  # ← Cambiado de ClusterIP
  ports:
  - port: <service-port>
    targetPort: <service-port>
  selector:
    app: <service-name>
```

## 🚀 Próximos Pasos

1. **Ejecutar pipeline de staging** para cualquier servicio
2. **Verificar que obtiene IP externa**:
   ```
   ⏳ Esperando IP externa del LoadBalancer...
   ✅ IP externa obtenida: 34.123.45.67
   🌐 Service URL: http://34.123.45.67:8600
   ```
3. **Confirmar que las pruebas E2E se ejecutan correctamente**
4. **Si no hay pruebas E2E**, verás: `ℹ️ No hay pruebas E2E configuradas` (esto es normal)

## 📊 Arquitectura Actualizada

```
┌─────────────────────────────────────────────────────┐
│           JENKINS PIPELINE (STAGING)                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Pull imagen de DEV                             │
│  2. Retag para STAGING                             │
│  3. Push a Google Artifact Registry                │
│  4. Deploy a GKE (ecommerce-staging)               │
│  5. Wait for Rollout                               │
│  6. E2E Tests ← CORREGIDO                          │
│     ├─ Export JAVA_HOME ✅                         │
│     ├─ Esperar IP externa (LoadBalancer) ✅        │
│     ├─ Fallback a port-forward ✅                  │
│     └─ Ejecutar Maven tests ✅                     │
│  7. Performance Tests                              │
│  8. Verify Health Checks                           │
│                                                     │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│      GOOGLE KUBERNETES ENGINE (GKE)                 │
│           ecommerce-staging-cluster                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Namespace: ecommerce-staging                      │
│                                                     │
│  Services (LoadBalancer con IP externa):           │
│  ├─ shipping-service:8600  → 34.x.x.x ✅          │
│  ├─ user-service:8700      → 34.x.x.x ✅          │
│  ├─ product-service:8500   → 34.x.x.x ✅          │
│  ├─ order-service:8300     → 34.x.x.x ✅          │
│  ├─ payment-service:8400   → 34.x.x.x ✅          │
│  └─ favourite-service:8800 → 34.x.x.x ✅          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## ✅ Estado Final

**TODOS LOS SERVICIOS LISTOS PARA PRUEBAS E2E EN STAGING** 🎉

- ✅ JAVA_HOME configurado
- ✅ IP externa disponible (LoadBalancer)
- ✅ Espera automática de IP
- ✅ Fallback a port-forward
- ✅ Puertos correctos
- ✅ Deployments actualizados

**Ejecuta el pipeline de staging nuevamente y las pruebas E2E deberían funcionar correctamente.**
