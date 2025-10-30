# Script para limpiar todos los deployments en ecommerce-dev
# Esto permite que Jenkins los recree con la configuracion correcta

Write-Host "Limpiando deployments en ecommerce-dev..." -ForegroundColor Cyan

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    Write-Host "`nEliminando deployment de $service..." -ForegroundColor Yellow
    docker exec jenkins kubectl delete deployment $service -n ecommerce-dev --ignore-not-found=true
    Write-Host "  Eliminado!" -ForegroundColor Green
}

Write-Host "`nVerificando pods restantes..." -ForegroundColor Yellow
docker exec jenkins kubectl get pods -n ecommerce-dev

Write-Host "`nLimpieza completada!" -ForegroundColor Green
Write-Host "Ahora puedes ejecutar los pipelines de Jenkins para recrear los deployments con la configuracion correcta" -ForegroundColor White
