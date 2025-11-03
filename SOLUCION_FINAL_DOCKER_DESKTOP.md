# Solución Final: Jenkins + Docker Desktop Kubernetes

## Estado Actual

✅ Docker Desktop Kubernetes está activo (v1.31.1)
✅ Namespace `ecommerce-dev` creado
✅ Jenkins está corriendo
❌ Jenkins no puede conectarse a Kubernetes (problema de configuración)

## Problema Identificado

Jenkins tiene configuraciones antiguas de Minikube que están interfiriendo con la conexión a Docker Desktop Kubernetes.

## Solución Más Simple

Hay 2 opciones:

---

### Opción 1: Usar Jenkinsfiles con kubectl desde el Host (RECOMENDADO)

En lugar de que Jenkins use kubectl desde dentro del contenedor, los Jenkinsfiles pueden ejecutar kubectl en el host.

**Ventajas:**
- No necesitas configurar kubeconfig en Jenkins
- Usa la configuración de kubectl que ya funciona en tu máquina
- Más simple y directo

**Cómo funciona:**

En el Jenkinsfile, en lugar de:
```groovy
sh 'kubectl apply -f k8s/'
```

Usa:
```groovy
bat 'kubectl apply -f k8s/'  // En Windows
```

O ejecuta kubectl desde el host usando Docker:
```groovy
sh '''
    docker run --rm -v ${WORKSPACE}:/workspace -v ${HOME}/.kube:/root/.kube \\
    bitnami/kubectl:latest apply -f /workspace/k8s/
'''
```

---

### Opción 2: Limpiar Completamente la Configuración de Jenkins

```powershell
# 1. Detener Jenkins
docker stop jenkins

# 2. Eliminar configuraciones antiguas de Kubernetes
docker run --rm -v jenkins_home:/data busybox rm -rf /data/.kube

# 3. Iniciar Jenkins
docker start jenkins

# 4. Copiar kubeconfig limpio
docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

# 5. Modificar el kubeconfig para usar host.docker.internal
# (Ejecutar el script que creamos)
./scripts/final-fix-jenkins-docker-desktop.ps1
```

---

## Opción 3: Usar Kind en lugar de Docker Desktop K8s

Kind es más fácil de configurar con Jenkins porque:
- Corre completamente en Docker
- No tiene problemas de red entre contenedores
- Más simple para CI/CD

```powershell
# Instalar Kind
choco install kind

# Ejecutar script de configuración
./scripts/setup-kind-cluster.ps1
```

---

## Mi Recomendación

**Para avanzar rápido:** Usa la **Opción 1** - ejecuta kubectl desde el host en los Jenkinsfiles.

**Para una solución más robusta:** Usa la **Opción 3** - Kind.

---

## Actualizar Jenkinsfiles para Opción 1

Necesitas modificar el stage de Deploy en los Jenkinsfiles:

### Antes:
```groovy
stage('Deploy to Kubernetes') {
    steps {
        script {
            sh '''
                kubectl apply -f order-service/k8s/
            '''
        }
    }
}
```

### Después (Windows):
```groovy
stage('Deploy to Kubernetes') {
    steps {
        script {
            // Guardar archivos K8s en el workspace
            bat '''
                kubectl apply -f order-service/k8s/
            '''
        }
    }
}
```

O usando Docker para ejecutar kubectl:
```groovy
stage('Deploy to Kubernetes') {
    steps {
        script {
            sh '''
                docker run --rm \\
                  --network host \\
                  -v ${WORKSPACE}/order-service/k8s:/k8s \\
                  -v ${HOME}/.kube:/root/.kube \\
                  bitnami/kubectl:latest apply -f /k8s/
            '''
        }
    }
}
```

---

## Verificar que Todo Funciona

Desde tu máquina (no desde Jenkins):

```powershell
# Ver que Kubernetes está funcionando
kubectl get nodes

# Ver namespace
kubectl get namespace ecommerce-dev

# Desplegar manualmente para probar
kubectl apply -f order-service/k8s/

# Ver el deployment
kubectl get pods -n ecommerce-dev
```

---

## Próximos Pasos

1. **Decide qué opción usar** (recomiendo Opción 1 o 3)
2. **Si eliges Opción 1:** Actualiza los Jenkinsfiles
3. **Si eliges Opción 3:** Instala Kind
4. **Prueba un pipeline**

¿Cuál opción prefieres?
