# Ejecutar Todos los Pipelines para Pruebas de Integración

## Problema Actual

Las pruebas de integración fallan con "Connection refused" porque necesitan que TODOS los servicios estén desplegados en Minikube, pero solo ejecutaste el pipeline de product-service.

## Solución: Ejecutar Pipelines en Orden

### 1. Servicios Base (sin dependencias)
Ejecuta estos primero:

```
user-service-pipeline (branch: dev)
product-service-pipeline (branch: dev)
```

### 2. Servicios con Dependencias
Después ejecuta estos:

```
order-service-pipeline (branch: dev)
payment-service-pipeline (branch: dev)
favourite-service-pipeline (branch: dev)
shipping-service-pipeline (branch: dev)
```

### 3. Verificar Despliegues

Después de ejecutar todos, verifica que estén corriendo:

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

### 4. Verificar Servicios

```powershell
kubectl get svc -n ecommerce-dev
```

Deberías ver todos los servicios con sus ClusterIP.

### 5. Ahora Sí: Ejecutar Pruebas de Integración

Una vez que TODOS los servicios estén desplegados y corriendo, ejecuta cualquier pipeline con las pruebas de integración habilitadas (sin marcar SKIP_TESTS).

## Opción Alternativa: Saltar Pruebas de Integración

Si solo quieres probar un servicio individual sin desplegar todos:

1. En Jenkins, al ejecutar el pipeline
2. Marca el parámetro `SKIP_TESTS = true`
3. Esto saltará tanto las pruebas unitarias como las de integración

## Por Qué Fallan las Pruebas

Las pruebas de integración hacen llamadas HTTP entre servicios:

- `UserOrderIntegrationTest` → necesita user-service + order-service
- `OrderPaymentIntegrationTest` → necesita order-service + payment-service
- `OrderShippingIntegrationTest` → necesita order-service + shipping-service
- `ProductFavouriteIntegrationTest` → necesita product-service + favourite-service

Si algún servicio no está desplegado, las pruebas fallan con "Connection refused".

## Resumen

**Para que las pruebas de integración pasen:**
1. Ejecuta los 6 pipelines (uno por servicio)
2. Espera a que todos estén en estado Running
3. Luego ejecuta cualquier pipeline con pruebas habilitadas

**Para desarrollo rápido de un solo servicio:**
- Usa `SKIP_TESTS = true` en los parámetros del pipeline
