# Configurar Minikube con Jenkins para Dev

## Situación Actual

- ✅ Jenkins corriendo en Docker
- ✅ GKE configurado y funcionando
- ✅ Minikube instalado en tu máquina
- ❌ Jenkins no puede acceder a Minikube (están en entornos separados)

## Problema

Jenkins (en Docker) necesita acceder a Minikube (en tu máquina local) para desplegar en dev.

## Solución: Configurar kubectl en Jenkins para Minikube

### Paso 1: Iniciar Minikube

```powershell
# Ejecutar como Administrador
minikube start --driver=docker
```

### Paso 2: Verificar que Minikube esté corriendo

```powershell
minikube status
kubectl get nodes
```

### Paso 3: Obtener la configuración de Minikube

```powershell
# Ver el archivo de configuración de kubectl
cat $HOME\.kube\config
```

### Paso 4: Copiar la configuración de Minikube a Jenkins

Necesitas copiar el archivo `~/.kube/config` de Minikube al contenedor de Jenkins.

**Opción A: Montar el archivo kubeconfig en Jenkins**

Editar `docker-compose.jenkins.yml` y agregar:

```yaml
volumes:
  - ${HOME}/.kube/config:/root/.kube/config:ro
```

**Opción B: Copiar manualmente al contenedor**

```powershell
# Obtener el ID del contenedor de Jenkins
docker ps | findstr jenkins

# Copiar el archivo
docker cp $HOME\.kube\config <jenkins-container-id>:/root/.kube/config
```

### Paso 5: Configurar kubectl en Jenkins para usar Minikube

Dentro del Jenkinsfile.dev, agregar antes del deploy:

```groovy
sh """
    # Cambiar contexto a Minikube
    kubectl config use-context minikube
    
    # Verificar conexión
    kubectl cluster-info
"""
```

### Paso 6: Actualizar Jenkinsfile.dev

El Jenkinsfile.dev debe:
1. Cambiar contexto a Minikube
2. Construir imagen local
3. Cargar imagen en Minikube
4. Desplegar en Minikube

## Alternativa Más Simple

Si esto es muy complejo, puedes usar **GKE para todos los ambientes** con diferentes namespaces:

- `ecommerce-dev` → GKE (simula local)
- `ecommerce-staging` → GKE
- `ecommerce-prod` → GKE

Esto cumple el objetivo del taller sin la complejidad de configurar Minikube en Jenkins.

## Decisión

¿Qué prefieres?
1. **Configurar Minikube** (más complejo, más "real")
2. **Usar GKE para todo** (más simple, funciona igual)

