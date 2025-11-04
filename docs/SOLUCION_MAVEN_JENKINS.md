# Solución: Maven no encontrado en Jenkins

## Problema
El pipeline de Jenkins falla con el error:
```
mvn: not found
script returned exit code 127
```

## Causa
El contenedor Jenkins base no incluye Maven, Docker CLI ni kubectl.

## Solución Implementada

### 1. Imagen Docker Personalizada de Jenkins
Creamos un Dockerfile personalizado que incluye todas las herramientas necesarias:

**Archivo:** `jenkins/Dockerfile`
- Jenkins LTS base
- Docker CLI (para construir imágenes)
- kubectl (para desplegar en Minikube)
- Maven 3.8.7 (para compilar proyectos Java)

### 2. Docker Compose Actualizado
Modificamos `docker-compose.jenkins.yml` para usar la imagen personalizada:
```yaml
services:
  jenkins:
    build:
      context: ./jenkins
      dockerfile: Dockerfile
    image: jenkins-custom:latest
```

### 3. Jenkinsfiles Actualizados
Los Jenkinsfiles ahora usan `agent any` en lugar de un agente Docker separado, ya que Jenkins tiene Maven instalado.

## Herramientas Verificadas en Jenkins

✅ **Maven**: 3.8.7
✅ **Docker CLI**: 28.5.1
✅ **kubectl**: v1.34.1
✅ **Java**: 21.0.8

## Problema Pendiente: Acceso a Minikube

Jenkins aún no puede conectarse al API server de Minikube. El error indica:
```
invalid character '<' looking for beginning of value
```

### Opciones para Resolver

**Opción A: Usar docker exec para kubectl**
En lugar de que Jenkins ejecute kubectl directamente, puede ejecutar comandos dentro del contenedor de Minikube:
```bash
docker exec minikube kubectl get pods
```

**Opción B: Exponer API de Minikube**
Configurar Minikube para que su API sea accesible desde otros contenedores Docker.

**Opción C: Usar Kind en lugar de Minikube**
Kind (Kubernetes in Docker) es más fácil de integrar con Jenkins ya que ambos corren en Docker.

## Scripts Creados

1. `scripts/fix-maven-in-jenkinsfiles.ps1` - Agrega agente Docker con Maven
2. `scripts/clean-java-home-from-jenkinsfiles.ps1` - Limpia configuración innecesaria
3. `scripts/revert-to-agent-any.ps1` - Revierte a agent any
4. `scripts/rebuild-jenkins-with-tools.ps1` - Reconstruye Jenkins con herramientas
5. `scripts/configure-jenkins-kubeconfig.ps1` - Configura kubeconfig
6. `scripts/create-jenkins-kubeconfig.ps1` - Crea kubeconfig con certificados embebidos
7. `scripts/fix-jenkins-minikube-access.ps1` - Intenta configurar acceso a Minikube
8. `scripts/check-jenkins-tools.ps1` - Verifica herramientas instaladas

## Próximos Pasos

1. Decidir entre las opciones A, B o C para el acceso a Kubernetes
2. Actualizar los Jenkinsfiles para usar la opción elegida
3. Probar el pipeline completo
