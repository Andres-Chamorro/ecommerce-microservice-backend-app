# Solución Simple para Pruebas de Integración

## El Problema

Las pruebas de integración fallan con "Connection refused" porque necesitan que los 6 servicios estén desplegados en Minikube.

## La Solución Más Simple y Confiable

**Ejecuta los 6 pipelines en Jenkins una vez.** Esto desplegará todos los servicios correctamente.

### Paso 1: Ejecutar Pipelines en Jenkins

Ve a Jenkins y ejecuta estos pipelines en orden (branch `dev`):

1. `user-service-pipeline`
2. `product-service-pipeline`
3. `order-service-pipeline`
4. `payment-service-pipeline`
5. `favourite-service-pipeline`
6. `shipping-service-pipeline`

**Parámetros para cada pipeline:**
- ✓ Deja `SKIP_TESTS = false` (o márcalo como `true` para que sea más rápido)
- ✓ Deja `SKIP_DEPLOY = false`

**Tiempo estimado:** 5-10 minutos por pipeline = 30-60 minutos total

### Paso 2: Verificar que Todos Estén Corriendo

Después de ejecutar los 6 pipelines:

```powershell
kubectl get pods -n ecommerce-dev
```

Deberías ver algo como:
```
NAME                                READY   STATUS    RESTARTS   AGE
user-service-xxx                    1/1     Running   0          5m
product-service-xxx                 1/1     Running   0          4m
order-service-xxx                   1/1     Running   0          3m
payment-service-xxx                 1/1     Running   0          2m
favourite-service-xxx               1/1     Running   0          1m
shipping-service-xxx                1/1     Running   0          30s
```

### Paso 3: Ahora Ejecuta Pruebas de Integración

Una vez que todos los servicios estén corriendo, ejecuta cualquier pipeline **SIN** marcar `SKIP_TESTS`:

- Las pruebas unitarias pasarán ✓
- Las pruebas de integración pasarán ✓ (porque todos los servicios están desplegados)

## Por Qué Esta Es la Mejor Solución

✓ **Confiable:** Los pipelines ya funcionan correctamente
✓ **Consistente:** Usa el mismo proceso que usarás en producción
✓ **Probado:** Ya sabes que los pipelines individuales funcionan
✓ **Mantenible:** No dependes de scripts externos

## Alternativa: Saltar Pruebas de Integración

Si solo quieres probar un servicio individual sin desplegar todos:

1. Marca `SKIP_TESTS = true` en los parámetros del pipeline
2. El pipeline solo hará build y deploy, sin pruebas

## Para Desarrollo Rápido

Una vez que todos los servicios estén desplegados:

- Puedes actualizar un solo servicio ejecutando solo su pipeline
- Los otros servicios seguirán corriendo
- Las pruebas de integración funcionarán porque todos los servicios están disponibles

## Comandos Útiles

```powershell
# Ver todos los pods
kubectl get pods -n ecommerce-dev

# Ver logs de un servicio
kubectl logs -n ecommerce-dev -l app=user-service -f

# Reiniciar un servicio
kubectl rollout restart deployment/user-service -n ecommerce-dev

# Eliminar todo y empezar de cero
kubectl delete namespace ecommerce-dev
```

## Resumen

1. Ejecuta los 6 pipelines en Jenkins (una sola vez)
2. Verifica que todos los pods estén Running
3. Ejecuta cualquier pipeline con pruebas habilitadas
4. ✓ Las pruebas de integración deberían pasar

**Esto es más simple y confiable que intentar desplegar manualmente desde la consola.**
