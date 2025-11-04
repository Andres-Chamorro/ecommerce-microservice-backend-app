# Desplegar Servicios Manualmente para Pruebas de Integración

## El Problema

Las pruebas de integración en Jenkins fallan porque necesitan que todos los servicios estén desplegados en Minikube, pero ejecutar 6 pipelines es lento.

## La Solución

Desplegar todos los servicios manualmente desde tu consola local, y luego Jenkins solo verificará que estén corriendo.

## Opción 1: Desplegar Todos los Servicios (Recomendado)

Ejecuta este script para construir y desplegar todos los servicios de una vez:

```powershell
./scripts/deploy-all-services-manually.ps1
```

Este script:
1. ✓ Crea el namespace `ecommerce-dev`
2. ✓ Construye las 6 imágenes Docker
3. ✓ Las carga en Minikube
4. ✓ Despliega todos los servicios en Kubernetes
5. ✓ Espera a que todos estén corriendo

**Tiempo estimado:** 5-10 minutos

## Opción 2: Desplegar Solo los Servicios Faltantes (Más Rápido)

Si ya tienes algunos servicios desplegados, usa este script que solo despliega los que faltan:

```powershell
./scripts/quick-deploy-missing-services.ps1
```

Este script:
1. ✓ Verifica qué servicios ya están desplegados
2. ✓ Te pregunta si quieres desplegar los faltantes
3. ✓ Solo construye y despliega los que faltan

## Verificar que Todo Está Corriendo

Después de ejecutar cualquiera de los scripts, verifica:

```powershell
# Ver todos los pods
kubectl get pods -n ecommerce-dev

# Deberías ver algo como:
# NAME                                READY   STATUS    RESTARTS   AGE
# user-service-xxx                    1/1     Running   0          2m
# product-service-xxx                 1/1     Running   0          2m
# order-service-xxx                   1/1     Running   0          2m
# payment-service-xxx                 1/1     Running   0          2m
# favourite-service-xxx               1/1     Running   0          2m
# shipping-service-xxx                1/1     Running   0          2m
```

```powershell
# Ver todos los servicios
kubectl get svc -n ecommerce-dev

# Deberías ver los 6 servicios con sus ClusterIP
```

## Ahora Ejecuta el Pipeline en Jenkins

Una vez que todos los servicios estén corriendo:

1. Ve a Jenkins
2. Ejecuta cualquier pipeline (ejemplo: `product-service-pipeline`)
3. **NO marques** `SKIP_TESTS`
4. Las pruebas de integración deberían pasar ✓

## Ventajas de Este Enfoque

✓ **Más rápido:** Despliegas una sola vez desde tu consola
✓ **Reutilizable:** Los servicios quedan corriendo para múltiples ejecuciones del pipeline
✓ **Flexible:** Puedes actualizar un solo servicio ejecutando su pipeline
✓ **Debugging fácil:** Puedes ver logs directamente con kubectl

## Comandos Útiles

```powershell
# Ver logs de un servicio
kubectl logs -n ecommerce-dev -l app=user-service -f

# Reiniciar un servicio
kubectl rollout restart deployment/user-service -n ecommerce-dev

# Eliminar todos los servicios (para empezar de cero)
kubectl delete namespace ecommerce-dev

# Ver estado de un pod específico
kubectl describe pod -n ecommerce-dev -l app=user-service
```

## Actualizar un Servicio Individual

Si haces cambios en un servicio y quieres actualizarlo:

**Opción A: Desde consola (más rápido)**
```powershell
# Ejemplo para user-service
docker build -t user-service:dev-manual -f user-service/Dockerfile .
docker save user-service:dev-manual | docker exec -i minikube ctr -n k8s.io images import -
kubectl rollout restart deployment/user-service -n ecommerce-dev
```

**Opción B: Desde Jenkins**
- Ejecuta solo el pipeline de ese servicio
- Marca `SKIP_TESTS = true` para que sea más rápido

## Troubleshooting

### Los pods no arrancan (CrashLoopBackOff)
```powershell
# Ver logs del pod
kubectl logs -n ecommerce-dev -l app=user-service

# Ver eventos
kubectl get events -n ecommerce-dev --sort-by='.lastTimestamp'
```

### Imagen no encontrada (ImagePullBackOff)
```powershell
# Verificar que la imagen está en Minikube
docker exec minikube ctr -n k8s.io images ls | grep user-service

# Si no está, reconstruir y cargar
docker build -t user-service:dev-manual -f user-service/Dockerfile .
docker save user-service:dev-manual | docker exec -i minikube ctr -n k8s.io images import -
```

### Un servicio no responde
```powershell
# Verificar que el pod está corriendo
kubectl get pods -n ecommerce-dev -l app=user-service

# Hacer port-forward para probar localmente
kubectl port-forward -n ecommerce-dev svc/user-service 8700:8700

# Probar en otra terminal
curl http://localhost:8700/actuator/health
```

## Resumen

1. Ejecuta `./scripts/deploy-all-services-manually.ps1`
2. Espera a que todos los pods estén Running
3. Ejecuta pipelines en Jenkins sin `SKIP_TESTS`
4. ✓ Las pruebas de integración deberían pasar
