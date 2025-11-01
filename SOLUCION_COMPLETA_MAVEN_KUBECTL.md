# Solución Completa: Maven y kubectl en Jenkins

## Problemas Resueltos

### 1. Maven no encontrado ✅
**Error:** `mvn: not found - script returned exit code 127`

**Solución:** Creamos una imagen Docker personalizada de Jenkins que incluye Maven.

**Archivos:**
- `jenkins/Dockerfile` - Dockerfile con Maven, Docker CLI y kubectl instalados
- `docker-compose.jenkins.yml` - Actualizado para usar la imagen personalizada

### 2. kubectl no puede conectarse a Minikube ✅
**Error:** `invalid character '<' looking for beginning of value`

**Solución:** Usamos `docker exec minikube kubectl` en lugar de ejecutar kubectl directamente desde Jenkins.

**Razón:** Jenkins y Minikube corren en contenedores Docker separados. La forma más simple de que Jenkins ejecute comandos kubectl es ejecutarlos dentro del contenedor de Minikube.

## Cambios Implementados

### 1. Imagen Docker Personalizada de Jenkins

```dockerfile
FROM jenkins/jenkins:lts

USER root

# Instalar Docker CLI
RUN apt-get update && \
    apt-get install -y docker-ce-cli

# Instalar kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar Maven
RUN apt-get install -y maven

USER jenkins
```

### 2. Jenkinsfiles Actualizados

**Cambios principales:**
- `agent any` - Usa Jenkins directamente (que ahora tiene Maven)
- `docker exec minikube kubectl` - Todos los comandos kubectl se ejecutan dentro de Minikube
- Archivos temporales para deployments - Evita problemas con pipes y here-docs

**Ejemplo de Deploy Stage:**
```groovy
stage('Deploy to Minikube') {
    steps {
        sh """
            # Crear namespace
            docker exec minikube kubectl get namespace ${K8S_NAMESPACE} || \
            docker exec minikube kubectl create namespace ${K8S_NAMESPACE}
            
            # Crear archivo de deployment
            cat > /tmp/deployment-${SERVICE_NAME}.yaml <<'EOFYAML'
apiVersion: apps/v1
kind: Deployment
...
EOFYAML
            
            # Copiar y aplicar
            docker cp /tmp/deployment-${SERVICE_NAME}.yaml minikube:/tmp/
            docker exec minikube kubectl apply -f /tmp/deployment-${SERVICE_NAME}.yaml
            
            # Limpiar
            rm -f /tmp/deployment-${SERVICE_NAME}.yaml
            docker exec minikube rm -f /tmp/deployment-${SERVICE_NAME}.yaml
        """
    }
}
```

## Herramientas Verificadas

✅ **Maven**: 3.8.7  
✅ **Docker CLI**: 28.5.1  
✅ **kubectl**: v1.34.1  
✅ **Java**: 21.0.8  

## Scripts Creados

1. `scripts/fix-maven-in-jenkinsfiles.ps1` - Agrega agente Docker con Maven (obsoleto)
2. `scripts/revert-to-agent-any.ps1` - Revierte a agent any
3. `scripts/rebuild-jenkins-with-tools.ps1` - Reconstruye Jenkins con herramientas
4. `scripts/update-jenkinsfiles-docker-exec-kubectl.ps1` - Actualiza kubectl commands
5. `scripts/deploy-clean-jenkinsfiles.ps1` - Despliega Jenkinsfiles limpios a todos los servicios
6. `scripts/check-jenkins-tools.ps1` - Verifica herramientas instaladas

## Cómo Usar

### 1. Reconstruir Jenkins (si es necesario)
```powershell
./scripts/rebuild-jenkins-with-tools.ps1
```

### 2. Verificar que Minikube está corriendo
```powershell
minikube status
```

### 3. Ejecutar Pipeline en Jenkins
1. Accede a Jenkins: http://localhost:8079
2. Selecciona el pipeline del servicio (ej: user-service-pipeline)
3. Selecciona la rama `dev`
4. Click en "Build with Parameters"
5. Configura los parámetros:
   - SKIP_TESTS: false (para ejecutar tests)
   - SKIP_DEPLOY: false (para desplegar)
6. Click en "Build"

## Flujo del Pipeline

1. **Checkout** - Clona el repositorio
2. **Build Maven** - Compila con `mvn clean package -DskipTests`
3. **Unit Tests** - Ejecuta tests unitarios (si SKIP_TESTS=false)
4. **Build Docker Image** - Construye imagen y la carga en Minikube
5. **Deploy to Minikube** - Despliega en Minikube usando kubectl
6. **Verify Deployment** - Verifica que el pod está Running
7. **Integration Tests** - Ejecuta tests de integración (si configurados)

## Ventajas de esta Solución

✅ **Simple** - No requiere configuración compleja de kubeconfig  
✅ **Confiable** - kubectl se ejecuta donde Kubernetes está corriendo  
✅ **Mantenible** - Imagen Docker personalizada con todas las herramientas  
✅ **Portable** - Funciona en cualquier máquina con Docker y Minikube  

## Troubleshooting

### Jenkins no puede ejecutar docker exec
**Solución:** Verifica que el socket de Docker está montado:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### Minikube no está accesible
**Solución:** Verifica que Minikube está corriendo:
```powershell
minikube status
docker ps | grep minikube
```

### Maven falla al compilar
**Solución:** Verifica que Maven está instalado en Jenkins:
```powershell
docker exec jenkins mvn --version
```

## Próximos Pasos

1. ✅ Maven instalado y funcionando
2. ✅ kubectl funcionando via docker exec
3. ⏳ Probar pipeline completo end-to-end
4. ⏳ Configurar tests de integración
5. ⏳ Agregar stages para staging y production
