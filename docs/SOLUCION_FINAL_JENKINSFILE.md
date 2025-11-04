# Solución Final: Jenkinsfile vs Jenkinsfile.dev

## Problema Identificado
Jenkins estaba usando `Jenkinsfile` (sin `.dev`) pero nosotros estábamos actualizando `Jenkinsfile.dev`. Por eso los cambios no se aplicaban.

## Causa
- Jenkins por defecto busca un archivo llamado `Jenkinsfile` en la raíz de cada servicio
- Teníamos dos archivos:
  - `Jenkinsfile` - El que Jenkins realmente usa
  - `Jenkinsfile.dev` - El que estábamos actualizando

## Solución Implementada

### 1. Actualizar Jenkinsfile.dev con docker save/load
Configuración correcta para cargar imágenes en Minikube desde Jenkins:

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
    docker exec minikube crictl images | grep ${IMAGE_NAME} || echo "WARNING: Imagen no encontrada"
"""
```

### 2. Copiar Jenkinsfile.dev a Jenkinsfile
Creamos el script `scripts/copy-jenkinsfile-dev-to-main.ps1` para copiar la configuración actualizada:

```powershell
.\scripts\copy-jenkinsfile-dev-to-main.ps1
```

### 3. Mantener imagePullPolicy: Never
Para forzar el uso de imágenes locales:

```yaml
imagePullPolicy: Never
```

## Scripts Creados

### update-all-jenkinsfiles-docker-save-load.ps1
Actualiza todos los Jenkinsfiles con la estrategia docker save/load y los copia a los archivos principales.

### copy-jenkinsfile-dev-to-main.ps1
Copia Jenkinsfile.dev a Jenkinsfile en todos los servicios.

### clean-all-deployments.ps1
Elimina todos los deployments antiguos para que Jenkins los recree con la configuración correcta.

## Estrategia docker save/load

Esta estrategia funciona porque:

1. **docker build** - Construye la imagen en el Docker daemon del host (Jenkins)
2. **docker save** - Exporta la imagen a un archivo tar
3. **docker cp** - Copia el archivo tar al contenedor Minikube
4. **ctr images import** - Importa la imagen en el runtime de contenedores de Minikube (containerd)
5. **crictl images** - Verifica que la imagen esté disponible en Minikube

## Servicios Actualizados
✅ user-service
✅ product-service
✅ order-service
✅ payment-service
✅ favourite-service
✅ shipping-service

## Verificación
Para verificar que la imagen se cargó correctamente en Minikube:

```powershell
# Ver imágenes en Minikube
docker exec minikube crictl images | Select-String "service"

# Ver pods
docker exec jenkins kubectl get pods -n ecommerce-dev

# Ver logs de un pod
docker exec jenkins kubectl logs -n ecommerce-dev -l app=order-service
```

## Próximos Pasos
1. Ejecuta el pipeline de Jenkins para order-service
2. Verifica que la imagen se construya y cargue correctamente
3. Verifica que el pod llegue a estado Running
4. Repite para los demás servicios

## Commit Realizado
```
fix: Actualizar Jenkinsfiles principales con docker save/load para Minikube

- Copiar configuracion de Jenkinsfile.dev a Jenkinsfile (que es el que usa Jenkins)
- Usar estrategia docker save/load para cargar imagenes en Minikube
- Actualizar todos los 6 servicios
- imagePullPolicy: Never para forzar uso de imagenes locales
```
