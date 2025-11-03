# ¿Funciona Jenkins + Minikube? 

## Respuesta: NO, todavía no

### ¿Por qué?

**Minikube no está instalado.** Sin Minikube, no hay cluster de Kubernetes donde desplegar los servicios.

### ¿Qué está funcionando?

✅ Jenkins está corriendo (puerto 8079)
✅ Docker está funcionando
✅ kubectl está instalado
✅ Jenkinsfiles están configurados

### ¿Qué falta?

❌ Minikube (el cluster de Kubernetes local)

---

## Para que funcione, haz esto:

### 1. Instala Minikube

```powershell
choco install minikube
```

O descarga desde: https://minikube.sigs.k8s.io/docs/start/

### 2. Inicia Minikube

```powershell
# Cierra y abre PowerShell después de instalar
minikube start --driver=docker
```

### 3. Ejecuta el script de configuración

```powershell
./scripts/setup-jenkins-minikube-complete.ps1
```

### 4. Copia kubeconfig a Jenkins

```powershell
docker exec jenkins mkdir -p /var/jenkins_home/.kube
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config
```

### 5. Prueba un pipeline

Ve a http://localhost:8079 y ejecuta el pipeline de `order-service`

---

## ¿Cuánto tiempo toma?

⏱️ **20-30 minutos** en total

---

## ¿Necesitas más detalles?

Lee: `PASOS_CONFIGURACION_MINIKUBE_JENKINS.md`
