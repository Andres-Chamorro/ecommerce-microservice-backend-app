# Configuración Pendiente para Staging

## ✅ Completado

1. **Cluster GKE**: `ecommerce-staging-cluster` en `us-central1-a` - EXISTE
2. **Docker Registry**: `us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry` - EXISTE
3. **gcloud SDK instalado en Jenkins** - INSTALADO
4. **kubectl instalado en Jenkins** - INSTALADO
5. **Jenkinsfiles de staging** - COPIADOS y LISTOS
6. **Fix de junit** - APLICADO (archiveArtifacts)

## ❌ Pendiente - CRÍTICO

### 1. Autenticar gcloud en Jenkins

Necesitas autenticar Jenkins con GCP. Tienes 2 opciones:

#### Opción A: Service Account (Recomendado para producción)

```bash
# En tu máquina local
gcloud iam service-accounts create jenkins-gke --display-name="Jenkins GKE"

gcloud projects add-iam-policy-binding ecommerce-microservices-476519 \
    --member="serviceAccount:jenkins-gke@ecommerce-microservices-476519.iam.gserviceaccount.com" \
    --role="roles/container.developer"

gcloud projects add-iam-policy-binding ecommerce-microservices-476519 \
    --member="serviceAccount:jenkins-gke@ecommerce-microservices-476519.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"

gcloud iam service-accounts keys create jenkins-key.json \
    --iam-account=jenkins-gke@ecommerce-microservices-476519.iam.gserviceaccount.com

# Copiar al contenedor
docker cp jenkins-key.json jenkins:/var/jenkins_home/

# Autenticar
docker exec jenkins /root/google-cloud-sdk/bin/gcloud auth activate-service-account \
    --key-file=/var/jenkins_home/jenkins-key.json
```

#### Opción B: Usar tus credenciales (Rápido para taller)

```bash
# Entrar al contenedor
docker exec -it jenkins bash

# Autenticar (abrirá navegador)
/root/google-cloud-sdk/bin/gcloud auth login

# Configurar proyecto
/root/google-cloud-sdk/bin/gcloud config set project ecommerce-microservices-476519
```

### 2. Configurar Docker para Artifact Registry

```bash
docker exec jenkins /root/google-cloud-sdk/bin/gcloud auth configure-docker us-central1-docker.pkg.dev
```

### 3. Configurar kubectl para GKE

```bash
docker exec jenkins /root/google-cloud-sdk/bin/gcloud container clusters get-credentials ecommerce-staging-cluster \
    --zone=us-central1-a \
    --project=ecommerce-microservices-476519
```

### 4. Verificar configuración

```bash
# Verificar autenticación
docker exec jenkins /root/google-cloud-sdk/bin/gcloud auth list

# Verificar acceso a GKE
docker exec jenkins kubectl cluster-info

# Verificar acceso al registry
docker exec jenkins /root/google-cloud-sdk/bin/gcloud artifacts docker images list us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry
```

## 📋 Checklist Final

Antes de ejecutar el pipeline de staging:

- [ ] gcloud autenticado en Jenkins
- [ ] Docker configurado para Artifact Registry
- [ ] kubectl configurado para GKE
- [ ] Namespace `ecommerce-staging` creado en GKE
- [ ] Jenkinsfiles de staging en rama staging
- [ ] Push de cambios a GitHub

## 🚀 Después de Configurar

1. Hacer commit y push de los cambios en staging
2. Jenkins detectará automáticamente la rama staging
3. Ejecutar el pipeline de staging
4. Verificar deployment en GKE:
   ```bash
   kubectl get pods -n ecommerce-staging
   kubectl get svc -n ecommerce-staging
   ```

## ⚠️ Notas Importantes

- Los Jenkinsfiles de staging esperan que las imágenes de dev ya estén en el registry
- Si no existen imágenes de dev, el stage "Pull Image from Dev" fallará
- Puedes modificar el Jenkinsfile para hacer build si no existe la imagen
- Las pruebas E2E y Performance pueden fallar si no están configuradas

## 🔧 Troubleshooting

### Error: "gcloud: command not found"
- Verificar que PATH incluya `/root/google-cloud-sdk/bin`
- Agregar al Jenkinsfile: `PATH = "/root/google-cloud-sdk/bin:${env.PATH}"`

### Error: "permission denied" al acceder a GKE
- Verificar que la service account tenga rol `roles/container.developer`

### Error: "unauthorized" al push a registry
- Ejecutar: `gcloud auth configure-docker us-central1-docker.pkg.dev`

### Error: "namespace not found"
- Crear namespace: `kubectl create namespace ecommerce-staging`
