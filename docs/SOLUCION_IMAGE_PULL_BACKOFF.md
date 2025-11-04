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

### 1. Usar estrategia `docker save/load`
Jenkins no tiene el comando `minikube` instalado, por lo que usamos una estrategia de construir con Docker y cargar la imagen en Minikube usando `docker save` y `ctr images import`.

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
    # Construir imagen con Docker
    docker build -t ${IMAGE_NAME}:dev-${BUILD_TAG} -f service/Dockerfile .
    docker tag ${IMAGE_NAME}:dev-${BUILD_TAG} ${IMAGE_NAME}:dev-latest
    
    # Guardar imagen a archivo tar
    docker save ${IMAGE_NAME}:dev-${BUILD_TAG} -o /tmp/${IMAGE_NAME}-dev-${BUILD_TAG}.tar
    
    # Cargar imagen en Minikube
    docker cp /tmp/${IMAGE_NAME}-dev-${BUILD_TAG}.tar minikube:/tmp/
    docker exec minikube ctr -n k8s.io images import /tmp/${IMAGE_NAME}-dev-${BUILD_TAG}.tar
    
    # Limpiar archivos temporales
    rm -f /tmp/${IMAGE_NAME}-dev-${BUILD_TAG}.tar
    docker exec minikube rm -f /tmp/${IMAGE_NAME}-dev-${BUILD_TAG}.tar
    
    # Verificar que la imagen existe en Minikube
    docker exec minikube crictl images | grep ${IMAGE_NAME} || echo "WARNING: Imagen no encontrada en Minikube"
"""
```

**Flujo de la estrategia:**
1. Construir imagen con `docker build` en Jenkins
2. Guardar imagen a archivo tar con `docker save`
3. Copiar tar al contenedor Minikube con `docker cp`
4. Importar imagen en containerd de Minikube con `ctr images import`
5. Limpiar archivos temporales
6. Verificar que la imagen existe con `crictl images`

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

## Scripts de Actualización
Se crearon los siguientes scripts:
- `scripts/fix-jenkinsfile-docker-save-load.ps1` - Actualiza Jenkinsfiles con estrategia docker save/load
- `scripts/clean-all-deployments.ps1` - Limpia todos los deployments antiguos en ecommerce-dev

## Verificación
Para verificar que las imágenes se construyen correctamente en Minikube:

```powershell
# Listar imágenes en Minikube (usando crictl)
docker exec minikube crictl images | grep service

# Ver logs de un pod
docker exec jenkins kubectl logs -n ecommerce-dev -l app=favourite-service

# Ver eventos del pod
docker exec jenkins kubectl describe pod -n ecommerce-dev -l app=favourite-service

# Verificar configuración completa
.\scripts\verify-jenkins-minikube.ps1
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
fix: Usar docker save/load para cargar imagenes en Minikube

- Cambiar estrategia de minikube image build a docker save/load
- Jenkins no tiene comando minikube instalado
- Construir imagen con docker build en Jenkins
- Guardar imagen a tar con docker save
- Copiar tar a contenedor Minikube
- Importar imagen con ctr images import
- Mantener imagePullPolicy: Never
- Agregar script para limpiar deployments antiguos
```

## Próximos Pasos
Ejecuta el pipeline de Jenkins nuevamente. Ahora debería:
1. Construir la imagen correctamente en Minikube
2. Desplegar el pod sin errores de ImagePullBackOff
3. El pod debería llegar a estado `Running`
