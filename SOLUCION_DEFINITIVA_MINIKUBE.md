# Solución Definitiva: Jenkins + Minikube

## El Problema Real
Jenkins y Minikube son contenedores separados con sus propios Docker daemons. No pueden compartir imágenes directamente.

## La Solución Correcta
Configurar Jenkins para usar el Docker daemon de Minikube mediante variables de entorno.

## Implementación

### Opción 1: Usar `eval $(minikube docker-env)` en Jenkins

En el Jenkinsfile, antes de construir:

```groovy
sh """
    # Configurar para usar el Docker daemon de Minikube
    eval \$(minikube -p minikube docker-env)
    
    # Ahora docker build construirá directamente en Minikube
    docker build -t ${IMAGE_NAME}:dev-${BUILD_TAG} -f service/Dockerfile .
    
    # Verificar
    docker images | grep ${IMAGE_NAME}
"""
```

**Problema**: Jenkins no tiene el comando `minikube` instalado.

### Opción 2: Configurar variables de entorno manualmente

```groovy
sh """
    # Obtener configuración de Minikube
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.67.2:2376"
    export DOCKER_CERT_PATH="/var/jenkins_home/.minikube/certs"
    export MINIKUBE_ACTIVE_DOCKERD="minikube"
    
    # Construir en Minikube
    docker build -t ${IMAGE_NAME}:dev-${BUILD_TAG} -f service/Dockerfile .
"""
```

**Problema**: Necesitamos los certificados correctos.

### Opción 3: Usar el registry interno de Minikube (RECOMENDADO)

Esta es la solución que usa la comunidad:

1. **Habilitar el addon de registry en Minikube**
2. **Push imágenes al registry**
3. **Pull desde el registry en los deployments**

## Implementación de la Opción 3 (Registry)

### Paso 1: Verificar que el registry está habilitado

```powershell
# El puerto 5000 de Minikube debe estar expuesto
docker ps | Select-String "5000"
```

### Paso 2: Configurar Jenkins para hacer push al registry

En el Jenkinsfile:

```groovy
environment {
    REGISTRY = "localhost:61360"  // Puerto mapeado del registry de Minikube
    IMAGE_NAME = "${REGISTRY}/${SERVICE_NAME}"
}

sh """
    # Construir imagen
    docker build -t ${IMAGE_NAME}:dev-${BUILD_TAG} -f service/Dockerfile .
    
    # Push al registry de Minikube
    docker push ${IMAGE_NAME}:dev-${BUILD_TAG}
"""
```

### Paso 3: Actualizar deployment para usar el registry

```yaml
containers:
- name: service
  image: localhost:5000/service:dev-1
  imagePullPolicy: Always
```

## Solución que Vamos a Usar

Dado que el registry tiene problemas de configuración, usaremos una solución híbrida más simple:

**Construir la imagen normalmente y NO intentar cargarla en Minikube automáticamente.**

En su lugar:
1. Jenkins construye y testea
2. Guarda la imagen en su propio daemon
3. Un script post-build carga manualmente la imagen en Minikube cuando sea necesario

Esto separa las responsabilidades y es más mantenible.
