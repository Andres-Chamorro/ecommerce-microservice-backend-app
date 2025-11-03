# Solución: Deploy a Minikube desde Jenkins

## Problema
Jenkins no puede conectarse a la API de Minikube en `https://192.168.67.2:8443` porque están en redes Docker diferentes y hay un timeout de TLS handshake.

## Solución Recomendada

### Opción 1: Deploy Manual (MÁS SIMPLE)

1. **Jenkins construye la imagen** (ya funciona correctamente)
2. **Tú ejecutas el deploy manualmente** desde Windows

Después de que Jenkins termine el build, ejecuta desde PowerShell:

```powershell
# Configurar kubectl para Minikube
kubectl config use-context minikube

# Aplicar deployment
kubectl apply -f product-service/k8s/deployment.yaml
kubectl apply -f product-service/k8s/service.yaml

# Verificar
kubectl get pods -n ecommerce-dev
kubectl get svc -n ecommerce-dev
```

### Opción 2: Script Automatizado

Crea un script que ejecute el deploy automáticamente después del build:

```powershell
# scripts/deploy-to-minikube.ps1
param(
    [string]$ServiceName = "product-service",
    [string]$BuildTag = "latest"
)

Write-Host "Desplegando $ServiceName con tag $BuildTag..." -ForegroundColor Green

# Actualizar imagen en deployment
$deploymentFile = "$ServiceName/k8s/deployment.yaml"
(Get-Content $deploymentFile) -replace 'image:.*', "image: ${ServiceName}:dev-${BuildTag}" | Set-Content $deploymentFile

# Aplicar deployment
kubectl apply -f $deploymentFile
kubectl apply -f "$ServiceName/k8s/service.yaml"

# Verificar
kubectl rollout status deployment/$ServiceName -n ecommerce-dev --timeout=2m
kubectl get pods -n ecommerce-dev -l app=$ServiceName

Write-Host "Deploy completado!" -ForegroundColor Green
```

Uso:
```powershell
./scripts/deploy-to-minikube.ps1 -ServiceName product-service -BuildTag 123
```

### Opción 3: Webhook de Jenkins (AVANZADO)

Configura un webhook que Jenkins llame al terminar el build, y que ejecute el deploy desde tu máquina.

## Modificación del Jenkinsfile

Simplifica el Jenkinsfile para que solo construya la imagen:

```groovy
stage('Build Docker Image') {
    steps {
        script {
            echo "Construyendo imagen Docker..."
            sh """
                cd product-service
                docker build -t \${IMAGE_NAME}:dev-\${BUILD_TAG} .
                docker tag \${IMAGE_NAME}:dev-\${BUILD_TAG} \${IMAGE_NAME}:dev-latest
                
                echo "Imagen construida: \${IMAGE_NAME}:dev-\${BUILD_TAG}"
                echo "La imagen está disponible en Minikube (mismo Docker daemon)"
                echo ""
                echo "Para desplegar, ejecuta desde Windows:"
                echo "kubectl apply -f product-service/k8s/deployment.yaml"
                echo "kubectl apply -f product-service/k8s/service.yaml"
            """
        }
    }
}
```

## Recomendación

**Usa la Opción 1 (Deploy Manual)** por ahora. Es la más simple y confiable. Una vez que todo funcione bien, puedes automatizar con la Opción 2.

El problema de red entre Jenkins y Minikube es complejo de resolver y no vale la pena el esfuerzo cuando puedes ejecutar `kubectl` directamente desde tu máquina Windows que ya tiene acceso a Minikube.
