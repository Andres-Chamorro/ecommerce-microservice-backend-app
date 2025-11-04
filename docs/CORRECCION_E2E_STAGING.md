# 🔧 Corrección de Pruebas E2E en Staging

## 🔴 Problemas Identificados

### 1. **JAVA_HOME no configurado**
```
The JAVA_HOME environment variable is not defined correctly
```
- El stage E2E no exporta JAVA_HOME antes de ejecutar Maven

### 2. **SERVICE_URL vacío**
```
Service URL: :8200
```
- El servicio no tiene IP externa porque usa `ClusterIP` en lugar de `LoadBalancer`
- No hay espera para que GKE asigne la IP externa

### 3. **Puertos incorrectos**
- `favourite-service`: Jenkinsfile usa 8600 pero deployment usa 8800

## ✅ Soluciones Aplicadas

### ✅ Todos los servicios corregidos

- [x] **shipping-service** - Puerto 8600
- [x] **user-service** - Puerto 8700
- [x] **product-service** - Puerto 8500
- [x] **order-service** - Puerto 8300
- [x] **payment-service** - Puerto 8400
- [x] **favourite-service** - Puerto 8800 (corregido de 8600)

### Cambios aplicados a todos:
- [x] JAVA_HOME exportado en stage E2E
- [x] Espera de IP externa (hasta 2 minutos)
- [x] Fallback a port-forward si no hay IP
- [x] Deployments cambiados a LoadBalancer
- [x] Puertos verificados y corregidos

## 📋 Puertos Correctos

| Servicio | Puerto Real | Puerto en Jenkinsfile | Estado |
|----------|-------------|----------------------|--------|
| user-service | 8700 | 8700 | ✅ OK |
| product-service | 8500 | 8500 | ✅ OK |
| order-service | 8300 | 8300 | ✅ OK |
| payment-service | 8400 | 8400 | ✅ OK |
| shipping-service | 8600 | 8600 | ✅ OK |
| favourite-service | 8800 | 8600 | ❌ INCORRECTO |

## 🚀 Próximos Pasos

1. Aplicar las mismas correcciones a los demás servicios
2. Corregir el puerto de favourite-service
3. Ejecutar pipeline de staging nuevamente
4. Verificar que las pruebas E2E pasen correctamente

## 📝 Cambios Necesarios en Cada Jenkinsfile

```groovy
// Cambiar de:
sh """
    . /root/google-cloud-sdk/path.bash.inc
    SERVICE_URL=\$(kubectl get svc ...)
"""

// A:
sh '''
    . /root/google-cloud-sdk/path.bash.inc
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    
    # Esperar IP externa
    for i in {1..24}; do
        SERVICE_IP=$(kubectl get svc ${SERVICE_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$SERVICE_IP" ]; then
            break
        fi
        sleep 5
    done
    
    # Fallback a port-forward
    if [ -z "$SERVICE_IP" ]; then
        kubectl port-forward -n ${K8S_NAMESPACE} svc/${SERVICE_NAME} ${SERVICE_PORT}:${SERVICE_PORT} &
        PORT_FORWARD_PID=$!
        SERVICE_URL="localhost"
    else
        SERVICE_URL="$SERVICE_IP"
    fi
'''
```

## 📝 Cambios en Deployments

```yaml
# Cambiar de:
spec:
  type: ClusterIP

# A:
spec:
  type: LoadBalancer  # IP externa para pruebas E2E
```
