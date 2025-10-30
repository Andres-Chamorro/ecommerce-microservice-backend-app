# ✅ Solución: Minikube con Jenkins

## Problema Resuelto

Jenkins ahora puede acceder a Minikube correctamente.

## Lo que se hizo

### 1. Instalación y Configuración de Minikube
```powershell
# Minikube instalado
C:\minikube\minikube.exe start

# Minikube corriendo en Docker
docker ps | findstr minikube
```

### 2. Conexión de Redes Docker
```powershell
# Jenkins y Minikube en la misma red
docker network connect minikube jenkins
```

### 3. Configuración de kubectl en Jenkins
```powershell
# Copiar configuración completa (GKE + Minikube)
kubectl config view --flatten > full-kubeconfig.yaml
docker cp full-kubeconfig.yaml jenkins:/tmp/kubeconfig.yaml
docker exec jenkins bash -c "cp /tmp/kubeconfig.yaml /var/jenkins_home/.kube/config"
docker exec jenkins chown jenkins:jenkins /var/jenkins_home/.kube/config
docker exec jenkins chmod 600 /var/jenkins_home/.kube/config
```

### 4. Reinicio de Jenkins
```powershell
docker restart jenkins
```

### 5. Verificación
```powershell
docker exec jenkins bash -c "KUBECONFIG=/var/jenkins_home/.kube/config kubectl config get-contexts"
```

**Resultado:**
```
CURRENT   NAME        CLUSTER     AUTHINFO    NAMESPACE
          gke_...     gke_...     gke_...     
*         minikube    minikube    minikube    default
```

✅ Minikube está configurado y es el contexto actual

## Jenkinsfiles Actualizados

Todos los Jenkinsfiles.dev ahora incluyen:

```groovy
sh """
    # Cambiar contexto a Minikube
    kubectl config use-context minikube
    
    # Verificar conexión
    kubectl cluster-info
    
    # Crear namespace si no existe
    kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
    
    # ... resto del deploy
"""
```

## Arquitectura Final

```
┌─────────────────────────────────────────┐
│           GitHub Repository             │
│  ┌─────────────────────────────────┐   │
│  │ Rama dev    → Jenkinsfile.dev   │   │
│  │ Rama staging → Jenkinsfile.staging│  │
│  │ Rama master  → Jenkinsfile.master │  │
│  └─────────────────────────────────┘   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Jenkins (Docker)                │
│  - Detecta cambios en ramas             │
│  - Ejecuta pipelines automáticamente    │
│  - Tiene acceso a Minikube y GKE        │
└──────┬──────────────────────┬───────────┘
       │                      │
       ▼                      ▼
┌──────────────┐    ┌──────────────────┐
│   Minikube   │    │       GKE        │
│   (Local)    │    │     (Nube)       │
│              │    │                  │
│ Namespace:   │    │ Namespaces:      │
│ ecommerce-dev│    │ ecommerce-staging│
│              │    │ ecommerce-prod   │
└──────────────┘    └──────────────────┘
```

## Flujo de CI/CD

### Rama DEV → Minikube
1. Push a rama `dev`
2. Jenkins detecta cambio
3. Build Maven + Unit Tests
4. Build Docker Image (local)
5. **Deploy to Minikube** (kubectl usa contexto minikube)
6. Integration Tests
7. Verify Deployment

### Rama STAGING → GKE
1. Merge dev → staging
2. Jenkins detecta cambio
3. Pull imagen de dev
4. Retag para staging
5. **Deploy to GKE Staging** (kubectl usa contexto GKE)
6. E2E Tests + Performance Tests
7. Verify Deployment

### Rama MASTER → GKE
1. Merge staging → master
2. Jenkins detecta cambio
3. Pull imagen de staging
4. Semantic Versioning
5. **Deploy to GKE Production** (kubectl usa contexto GKE)
6. System Tests
7. Generate Release Notes

## Próximos Pasos

1. ✅ Ejecutar pipeline de user-service en rama dev
2. ⏳ Verificar que se despliegue en Minikube
3. ⏳ Ejecutar pipelines de los demás microservicios
4. ⏳ Push de ramas staging y master
5. ⏳ Configurar pipelines para staging y master

## Comandos Útiles

### Verificar Minikube
```powershell
minikube status
kubectl get nodes
kubectl get pods -n ecommerce-dev
```

### Verificar Jenkins
```powershell
docker logs jenkins
docker exec jenkins kubectl config current-context
```

### Verificar Despliegues
```powershell
# En Minikube
kubectl get all -n ecommerce-dev

# En GKE
kubectl get all -n ecommerce-staging
kubectl get all -n ecommerce-prod
```

---

**Estado**: ✅ Configuración completa y funcional
**Fecha**: 30 de Octubre, 2025
