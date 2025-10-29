# Script para configurar acceso de Jenkins a GKE
# Ejecutar en PowerShell como administrador

Write-Host "🔧 Configurando acceso de Jenkins a GKE..." -ForegroundColor Cyan

# Variables
$PROJECT_ID = "ecommerce-microservices-476519"
$CLUSTER_NAME = "ecommerce-staging-cluster"
$ZONE = "us-central1-a"
$SA_NAME = "jenkins-gke"
$SA_EMAIL = "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
$KEY_FILE = "jenkins-gcp-key.json"

# 1. Crear Service Account
Write-Host "`n📝 Creando Service Account..." -ForegroundColor Yellow
gcloud iam service-accounts create $SA_NAME `
    --display-name="Jenkins GKE Access" `
    --project=$PROJECT_ID

# 2. Dar permisos necesarios
Write-Host "`n🔐 Asignando permisos..." -ForegroundColor Yellow
gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/container.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/container.clusterViewer"

# 3. Crear y descargar la key
Write-Host "`n🔑 Generando key..." -ForegroundColor Yellow
gcloud iam service-accounts keys create $KEY_FILE `
    --iam-account=$SA_EMAIL `
    --project=$PROJECT_ID

# 4. Copiar key al contenedor de Jenkins
Write-Host "`n📦 Copiando key a Jenkins..." -ForegroundColor Yellow
docker cp $KEY_FILE jenkins:/var/jenkins_home/gcp-key.json
docker exec jenkins chown jenkins:jenkins /var/jenkins_home/gcp-key.json

# 5. Configurar gcloud en Jenkins
Write-Host "`n⚙️ Configurando gcloud en Jenkins..." -ForegroundColor Yellow
docker exec jenkins bash -c @"
. /root/google-cloud-sdk/path.bash.inc
gcloud auth activate-service-account --key-file=/var/jenkins_home/gcp-key.json
gcloud config set project $PROJECT_ID
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
"@

# 6. Verificar
Write-Host "`n✅ Verificando conexión..." -ForegroundColor Yellow
docker exec jenkins bash -c "export USE_GKE_GCLOUD_AUTH_PLUGIN=True && kubectl cluster-info"

Write-Host "`n✅ Configuración completada!" -ForegroundColor Green
Write-Host "`n📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Ir a Jenkins → Manage Jenkins → Credentials"
Write-Host "2. Agregar credencial 'Secret file' con ID 'gcp-service-account'"
Write-Host "3. Subir el archivo: $KEY_FILE"
Write-Host "4. Ejecutar el pipeline"

Write-Host "`n⚠️ IMPORTANTE: Guarda el archivo $KEY_FILE en un lugar seguro" -ForegroundColor Yellow
