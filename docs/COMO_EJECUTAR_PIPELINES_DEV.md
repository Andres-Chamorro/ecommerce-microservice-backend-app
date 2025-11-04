# Cómo Ejecutar los Pipelines en Dev

## Estado Actual
✅ Minikube está corriendo
✅ Namespace `ecommerce-dev` existe
✅ Jenkinsfiles configurados correctamente
✅ Pruebas de integración corregidas
⚠️ **Servicios NO están desplegados** (necesitas ejecutar los pipelines)

## Pasos para Desplegar los Servicios

### 1. Acceder a Jenkins
```
http://localhost:8080
```

### 2. Ejecutar Pipeline para Cada Servicio

Ejecuta los siguientes pipelines en este orden (o en paralelo):

1. **user-service-pipeline** (rama: dev)
2. **product-service-pipeline** (rama: dev)
3. **order-service-pipeline** (rama: dev)
4. **payment-service-pipeline** (rama: dev)
5. **favourite-service-pipeline** (rama: dev)
6. **shipping-service-pipeline** (rama: dev)

### 3. Parámetros del Pipeline

Cuando ejecutes cada pipeline, usa estos parámetros:
- ✅ **SKIP_TESTS**: false (ejecutar pruebas unitarias)
- ✅ **SKIP_DEPLOY**: false (desplegar en Minikube)

### 4. Lo que Hará el Pipeline

Cada pipeline ejecutará:
1. ✅ Checkout del código
2. ✅ Build con Maven (pruebas unitarias)
3. ✅ Build de imagen Docker
4. ✅ Carga de imagen en Minikube
5. ✅ Deploy en Kubernetes (namespace: ecommerce-dev)
6. ⚠️ Pruebas de integración (fallarán en el primer deploy - es normal)
7. ✅ Reportes de cobertura

### 5. Verificar Despliegue

Después de ejecutar los pipelines, verifica:

```powershell
# Ver pods desplegados
kubectl get pods -n ecommerce-dev

# Ver servicios
kubectl get svc -n ecommerce-dev

# Ver logs de un servicio
kubectl logs -n ecommerce-dev -l app=user-service
```

### 6. Segundo Deploy (Pruebas de Integración)

Una vez que TODOS los servicios estén desplegados:
- Ejecuta los pipelines nuevamente
- Esta vez las pruebas de integración SÍ pasarán
- Porque todos los servicios estarán disponibles

## Troubleshooting

### Si un pod no inicia (ImagePullBackOff)
```powershell
# Ver detalles del pod
kubectl describe pod <pod-name> -n ecommerce-dev

# Verificar imágenes en Minikube
minikube image ls | Select-String "service"
```

### Si las pruebas de integración fallan
- Es normal en el primer deploy
- Ejecuta los pipelines una segunda vez después de que todos los servicios estén corriendo

### Si Minikube no responde
```powershell
minikube status
minikube start
```

## Resumen

**Para que las pruebas de integración pasen:**
1. Ejecuta TODOS los pipelines (6 servicios)
2. Espera a que todos los pods estén en estado "Running"
3. Ejecuta los pipelines nuevamente
4. Las pruebas de integración ahora pasarán ✅

---

**Última actualización**: 2025-11-04
