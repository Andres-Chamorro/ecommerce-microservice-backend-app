# Configurar Jenkins para Acceder a GKE

## Problema Actual
Jenkins no puede conectarse al cluster de Kubernetes en GCP porque no tiene las credenciales configuradas.

Error:
```
error: invalid character '<' looking for beginning of value
```

## Solución Rápida para el Taller

### Paso 1: Crear Service Account en GCP

```bash
# En tu máquina local (Windows)
gcloud iam service-accounts create jenkins-gke --display-name="Jenkins GKE Access"

# Obtener el email de la service account
gcloud iam service-accounts list

# Dar permisos necesarios
gcloud projects add-iam-policy-binding ecommerce-microservices-476519 \
    --member="serviceAccount:jenkins-gke@ecommerce-microservices-476519.iam.gserviceaccount.com" \
    --role="roles/container.developer"

# Crear y descargar la key
gcloud iam service-accounts keys create jenkins-gcp-key.json \
    --iam-account=jenkins-gke@ecommerce-microservices-476519.iam.gserviceaccount.com
```

### Paso 2: Configurar Credenciales en Jenkins

1. **Ir a Jenkins** → Manage Jenkins → Credentials → System → Global credentials

2. **Agregar nueva credencial** (Secret file):
   - Kind: `Secret file`
   - File: Subir `jenkins-gcp-key.json`
   - ID: `gcp-service-account`
   - Description: `GCP Service Account for GKE`

3. **Agregar otra credencial** (Secret text):
   - Kind: `Secret text`
   - Secret: `ecommerce-microservices-476519`
   - ID: `gcp-project-id`
   - Description: `GCP Project ID`

### Paso 3: Verificar el Pipeline

El Jenkinsfile ya está configurado para usar estas credenciales en el stage "Authenticate with GCP".

## Alternativa: Usar Kubeconfig Directamente (Más Rápido para el Taller)

Si no quieres configurar service accounts, puedes usar tu kubeconfig directamente:

### Opción A: Copiar kubeconfig a Jenkins

```powershell
# En tu máquina Windows
# 1. Obtener el kubeconfig con token estático
gcloud container clusters get-credentials ecommerce-staging-cluster `
    --zone=us-central1-a `
    --project=ecommerce-microservices-476519

# 2. Copiar al contenedor de Jenkins
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

# 3. Entrar al contenedor y verificar
docker exec -it jenkins bash
kubectl cluster-info
```

### Opción B: Usar Plugin de Kubernetes en Jenkins

1. Instalar plugin: `Kubernetes CLI Plugin`
2. Configurar kubeconfig como credencial
3. Usar en el pipeline:

```groovy
stage('Deploy to Kubernetes') {
    steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
            sh 'kubectl get nodes'
        }
    }
}
```

## Solución Recomendada para el Taller

Para completar tu taller rápidamente, te recomiendo:

1. **Usar el Jenkinsfile.local** que ya creamos
2. **Copiar tu kubeconfig al contenedor de Jenkins**:

```powershell
# Crear directorio .kube en Jenkins
docker exec jenkins mkdir -p /var/jenkins_home/.kube

# Copiar kubeconfig
docker cp $env:USERPROFILE\.kube\config jenkins:/var/jenkins_home/.kube/config

# Dar permisos
docker exec jenkins chown jenkins:jenkins /var/jenkins_home/.kube/config
```

3. **Modificar el Jenkinsfile para no requerir autenticación GCP**

## Verificación

Después de configurar, verifica que funciona:

```bash
# Dentro del contenedor de Jenkins
docker exec -it jenkins bash
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

## Troubleshooting

### Error: "gke-gcloud-auth-plugin not found"

Instalar en el contenedor de Jenkins:
```bash
docker exec -it jenkins bash
curl https://sdk.cloud.google.com | bash
source /root/google-cloud-sdk/path.bash.inc
gcloud components install gke-gcloud-auth-plugin
```

### Error: "permission denied"

```bash
docker exec jenkins chown -R jenkins:jenkins /var/jenkins_home/.kube
```

### Error: "cluster not found"

Verificar que el kubeconfig tiene el contexto correcto:
```bash
docker exec jenkins kubectl config get-contexts
docker exec jenkins kubectl config use-context gke_ecommerce-microservices-476519_us-central1-a_ecommerce-staging-cluster
```
