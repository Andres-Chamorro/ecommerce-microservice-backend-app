# Verificar Configuración de Jenkins Multibranch

## Problema Actual
Solo payment-service se ejecuta. Los otros servicios muestran "no changes".

## Causa
Los Multibranch Pipelines no están configurados para buscar el Jenkinsfile en el subdirectorio correcto.

## Solución

### Para cada servicio en Jenkins:

1. **user-service**
   - Jenkins → user-service → Configure
   - Build Configuration → Script Path: `user-service/Jenkinsfile`
   - Save

2. **shipping-service**
   - Jenkins → shipping-service → Configure
   - Build Configuration → Script Path: `shipping-service/Jenkinsfile`
   - Save

3. **product-service**
   - Jenkins → product-service → Configure
   - Build Configuration → Script Path: `product-service/Jenkinsfile`
   - Save

4. **order-service**
   - Jenkins → order-service → Configure
   - Build Configuration → Script Path: `order-service/Jenkinsfile`
   - Save

5. **favourite-service**
   - Jenkins → favourite-service → Configure
   - Build Configuration → Script Path: `favourite-service/Jenkinsfile`
   - Save

6. **payment-service** (verificar que esté correcto)
   - Jenkins → payment-service → Configure
   - Build Configuration → Script Path: `payment-service/Jenkinsfile`
   - Save

## Después de configurar

1. En cada job, click en "Scan Multibranch Pipeline Now"
2. Debería detectar la rama `dev` y ejecutar el pipeline

## Alternativa: Usar Jenkins CLI o API

Si tienes muchos servicios, puedes usar Jenkins CLI para actualizar todos a la vez.
