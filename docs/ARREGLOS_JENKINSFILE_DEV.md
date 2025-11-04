# Arreglos Necesarios para Jenkinsfile.dev

## Problemas Identificados

### 1. Orden Incorrecto de Stages
**Problema**: Integration Tests se ejecutan ANTES de desplegar los servicios
**Solución**: Reordenar stages

**Orden Actual (Incorrecto)**:
```
1. Checkout
2. Build Maven
3. Unit Tests
4. Integration Tests ❌ (servicios no están corriendo)
5. Build Docker Image
6. Push to Registry ❌ (falla por GCR)
7. Deploy to Minikube (nunca llega)
8. Verify Deployment
```

**Orden Correcto**:
```
1. Checkout
2. Build Maven
3. Unit Tests
4. Build Docker Image
5. Deploy to Minikube ✅ (desplegar primero)
6. Integration Tests ✅ (ahora los servicios están corriendo)
7. Verify Deployment
```

### 2. Registry Remoto Innecesario
**Problema**: Jenkinsfile.dev intenta hacer push a GCR (Google Cloud Registry)
**Solución**: Usar imagen local de Docker para Minikube

**Cambios**:
- Eliminar: `DOCKER_REGISTRY = 'us-central1-docker.pkg.dev/...'`
- Cambiar: `IMAGE_NAME = "${SERVICE_NAME}"`
- Eliminar: Stage "Push to Registry"

### 3. Configuración de Minikube
Para que Minikube use imágenes locales de Docker:
```bash
eval $(minikube docker-env)
```

## Cambios a Realizar

### Para TODOS los servicios (user, product, order, payment, favourite, shipping):

1. **Editar `{service}/Jenkinsfile.dev`**:
   - Cambiar `IMAGE_NAME` para usar solo el nombre del servicio
   - Reordenar stages: mover "Integration Tests" después de "Deploy to Minikube"
   - Eliminar stage "Push to Registry"
   - Configurar para usar Docker local de Minikube

2. **Resultado Esperado**:
   - Build local sin push a registry
   - Deploy a Minikube con imagen local
   - Integration tests contra servicios desplegados en Minikube
   - Todo funciona localmente sin necesidad de GCP

## Siguiente Paso

¿Quieres que cree un script PowerShell para hacer estos cambios automáticamente en todos los Jenkinsfile.dev?
