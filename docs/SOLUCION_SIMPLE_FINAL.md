# Solución Simple y Rápida para Jenkins + Minikube

## El Problema
Jenkins no puede conectarse a la API de Kubernetes de Minikube por TLS handshake timeout.

## La Solución Simple
**En lugar de configurar redes y certificados complejos, simplemente ejecutamos kubectl DENTRO de Minikube desde Jenkins.**

## Cómo Funciona
En el Jenkinsfile, en lugar de:
```groovy
kubectl apply -f k8s/
```

Usamos:
```groovy
sh 'docker exec minikube kubectl apply -f k8s/'
```

## Ventajas
- ✅ No requiere configuración de red
- ✅ No requiere certificados TLS
- ✅ No requiere kubeconfig
- ✅ Funciona inmediatamente
- ✅ Jenkins y Minikube ya están en la misma red Docker

## Actualización del Jenkinsfile

Cambiar el stage de Deploy para usar `docker exec minikube kubectl`:

```groovy
stage('Deploy to Minikube') {
    when {
        expression { params.SKIP_DEPLOY == false }
    }
    steps {
        script {
            echo "[DEV] Desplegando en Minikube..."
            
            sh """
                # Crear namespace si no existe
                docker exec minikube kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | docker exec -i minikube kubectl apply -f -
                
                # Aplicar manifiestos K8s
                docker exec minikube kubectl apply -f ${SERVICE_NAME}/k8s/ -n ${K8S_NAMESPACE}
                
                # Verificar deployment
                docker exec minikube kubectl get pods -n ${K8S_NAMESPACE} -l app=${SERVICE_NAME}
                docker exec minikube kubectl get svc -n ${K8S_NAMESPACE} ${SERVICE_NAME}
            """
        }
    }
}
```

## Para Docker
Similar, usar:
```groovy
sh 'docker exec minikube docker build -t ${IMAGE_NAME}:${BUILD_TAG} .'
```

O mejor aún, construir en Jenkins y cargar en Minikube:
```groovy
sh 'docker build -t ${IMAGE_NAME}:${BUILD_TAG} .'
sh 'docker save ${IMAGE_NAME}:${BUILD_TAG} | docker exec -i minikube docker load'
```

## Resumen
Esta solución evita TODOS los problemas de conectividad usando docker exec para ejecutar comandos directamente dentro de Minikube.
