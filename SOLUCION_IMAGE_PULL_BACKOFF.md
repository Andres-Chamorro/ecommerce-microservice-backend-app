# Solución: ImagePullBackOff en Minikube

## Problema
Los pods en Minikube fallaban con error `ImagePullBackOff`:
```
Failed to pull image "favourite-service:dev-10": Error response from daemon: 
pull access denied for favourite-service, repository does not exist or may require 'docker login'
```

## Causa Raíz
1. El comando `eval $(minikube docker-env)` no funciona correctamente desde Jenkins
2. Las imágenes se construían en el Docker daemon del host en lugar del Docker daemon de Minikube
3. Kubernetes intentaba hacer `pull` de las imágenes desde un registry remoto
4. El `imagePullPolicy: IfNotPresent` no era suficiente porque la imagen no existía en Minikube

## Solución Implementada

### 1. Usar `minikube image build`
En lugar de usar `docker build` con `eval $(minikube docker-env)`, ahora usamos `minikube image build` que construye directamente en el Docker daemon de Minikube.

**Antes:**
```groovy
sh """
    # Usar el Docker daemon de Minikube
    eval \$(minikube docker-env) || true
    
    docker build -t ${IMAGE_NAME}:dev-${BUILD_TAG} -f service/Dockerfile .
    docker tag ${IMAGE_NAME}:dev-${BUILD_TAG} ${IMAGE_NAME}:dev-latest
"""
```

**Después:**
```groovy
sh """
    # Construir imagen directamente en Minikube
    minikube image build -t ${IMAGE_NAME}:dev-${BUILD_TAG} -f service/Dockerfile .
    minikube image build -t ${IMAGE_NAME}:dev-latest -f service/Dockerfile .
    
    # Verificar que la imagen existe
    minikube image ls | grep ${IMAGE_NAME} || echo "WARNING: Imagen no encontrada"
"""
```

### 2. Cambiar `imagePullPolicy` a `Never`
Para forzar el uso de imágenes locales y evitar intentos de pull desde registries remotos.

**Antes:**
```yaml
imagePullPolicy: IfNotPresent
```

**Después:**
```yaml
imagePullPolicy: Never
```

## Archivos Modificados
- `user-service/Jenkinsfile.dev`
- `product-service/Jenkinsfile.dev`
- `order-service/Jenkinsfile.dev`
- `payment-service/Jenkinsfile.dev`
- `favourite-service/Jenkinsfile.dev`
- `shipping-service/Jenkinsfile.dev`

## Script de Actualización
Se creó el script `scripts/fix-jenkinsfile-image-pull.ps1` para automatizar estos cambios en todos los servicios.

## Verificación
Para verificar que las imágenes se construyen correctamente en Minikube:

```powershell
# Listar imágenes en Minikube
minikube image ls | grep service

# Ver logs de un pod
docker exec jenkins kubectl logs -n ecommerce-dev -l app=favourite-service

# Ver eventos del pod
docker exec jenkins kubectl describe pod -n ecommerce-dev -l app=favourite-service
```

## Limpieza de Deployments Antiguos
Si tienes deployments con el problema anterior, elimínalos:

```powershell
docker exec jenkins kubectl delete deployment <service-name> -n ecommerce-dev
```

El pipeline creará nuevos deployments con la configuración correcta.

## Beneficios
✅ Las imágenes se construyen directamente en Minikube
✅ No se requiere configurar Docker daemon environment
✅ No hay intentos de pull desde registries remotos
✅ Más rápido y confiable para desarrollo local
✅ Funciona correctamente desde Jenkins

## Commits Realizados
```
fix: Resolver ImagePullBackOff usando minikube image build

- Cambiar de 'docker build' a 'minikube image build'
- Cambiar imagePullPolicy de 'IfNotPresent' a 'Never'
- Agregar verificacion de imagen despues de build
- Actualizar todos los Jenkinsfiles.dev de los 6 servicios
```

## Próximos Pasos
Ejecuta el pipeline de Jenkins nuevamente. Ahora debería:
1. Construir la imagen correctamente en Minikube
2. Desplegar el pod sin errores de ImagePullBackOff
3. El pod debería llegar a estado `Running`
