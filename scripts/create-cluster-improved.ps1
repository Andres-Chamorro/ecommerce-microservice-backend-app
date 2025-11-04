# Script para crear cluster GKE con configuracion mejorada
# Basado en configuracion recomendada

$CLUSTER_NAME = "ecommerce-staging-cluster"
$ZONE = "us-central1-a"
$PROJECT_ID = "ecommerce-microservices-476519"

Write-Host "Creando cluster GKE mejorado..." -ForegroundColor Green
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor Cyan
Write-Host "  - Tipo de maquina: e2-standard-2 (2 vCPU, 8 GB RAM)" -ForegroundColor White
Write-Host "  - Nodos iniciales: 3" -ForegroundColor White
Write-Host "  - Autoscaling: 2-4 nodos" -ForegroundColor White
Write-Host "  - Disco: 50 GB SSD" -ForegroundColor White
Write-Host "  - Auto-repair: Habilitado" -ForegroundColor White
Write-Host "  - Auto-upgrade: Habilitado" -ForegroundColor White
Write-Host ""

gcloud container clusters create $CLUSTER_NAME `
  --zone=$ZONE `
  --project=$PROJECT_ID `
  --machine-type=e2-standard-2 `
  --num-nodes=3 `
  --disk-size=50GB `
  --disk-type=pd-ssd `
  --image-type=COS_CONTAINERD `
  --enable-autoscaling `
  --min-nodes=2 `
  --max-nodes=4 `
  --enable-autorepair `
  --enable-autoupgrade `
  --enable-ip-alias `
  --network=default `
  --subnetwork=default `
  --no-enable-basic-auth `
  --no-issue-client-certificate `
  --enable-stackdriver-kubernetes `
  --addons=HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver

Write-Host ""
Write-Host "Cluster creado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Conectando kubectl al cluster..." -ForegroundColor Cyan
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

Write-Host ""
Write-Host "Verificando nodos..." -ForegroundColor Cyan
kubectl get nodes

Write-Host ""
Write-Host "Listo!" -ForegroundColor Green
