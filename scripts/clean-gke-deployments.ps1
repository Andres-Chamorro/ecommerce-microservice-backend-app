# Script para limpiar deployments en GKE y liberar recursos

Write-Host "Limpiando deployments en GKE..." -ForegroundColor Cyan
Write-Host ""

$namespace = "ecommerce-prod"
$services = @(
    "user-service",
    "order-service", 
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

Write-Host "=== PASO 1: Ver estado actual ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "Deployments:" -ForegroundColor White
kubectl get deployments -n $namespace

Write-Host "`nPods:" -ForegroundColor White
kubectl get pods -n $namespace

Write-Host "`nReplicaSets (historial):" -ForegroundColor White
kubectl get rs -n $namespace

Write-Host ""
Write-Host "=== PASO 2: Limpiar ReplicaSets antiguos ===" -ForegroundColor Yellow
Write-Host "Esto libera recursos y limpia el historial..." -ForegroundColor Gray
Write-Host ""

foreach ($service in $services) {
    Write-Host "Limpiando ReplicaSets de $service..." -ForegroundColor Cyan
    kubectl delete rs -n $namespace -l app=$service --field-selector status.replicas=0 2>$null
}

Write-Host ""
Write-Host "=== PASO 3: Reiniciar deployments ===" -ForegroundColor Yellow
Write-Host "Esto fuerza un rollout limpio..." -ForegroundColor Gray
Write-Host ""

foreach ($service in $services) {
    Write-Host "Reiniciando $service..." -ForegroundColor Cyan
    kubectl rollout restart deployment/$service -n $namespace
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "=== PASO 4: Esperar a que se estabilicen ===" -ForegroundColor Yellow
Write-Host "Esperando 30 segundos..." -ForegroundColor Gray
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "=== PASO 5: Verificar estado final ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "Deployments:" -ForegroundColor White
kubectl get deployments -n $namespace

Write-Host "`nPods:" -ForegroundColor White
kubectl get pods -n $namespace

Write-Host ""
Write-Host "Limpieza completada!" -ForegroundColor Green
Write-Host ""
Write-Host "Que esperar:" -ForegroundColor Cyan
Write-Host "- Los pods viejos se estan terminando" -ForegroundColor White
Write-Host "- Los pods nuevos estan arrancando" -ForegroundColor White
Write-Host "- En 2-5 minutos todo deberia estar Running" -ForegroundColor White
Write-Host ""
Write-Host "Ahora puedes ejecutar tu pipeline de nuevo." -ForegroundColor Green
