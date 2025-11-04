# Script para diagnosticar y arreglar deployments en GKE

Write-Host "Diagnosticando deployments en GKE..." -ForegroundColor Cyan
Write-Host ""

$namespace = "ecommerce-prod"
$services = @("user-service", "favourite-service")

Write-Host "Verificando estado de deployments..." -ForegroundColor Yellow
Write-Host ""

foreach ($service in $services) {
    Write-Host "=== $service ===" -ForegroundColor Cyan
    
    # Ver estado del deployment
    Write-Host "Estado del deployment:" -ForegroundColor White
    kubectl get deployment $service -n $namespace
    
    # Ver pods
    Write-Host "`nPods:" -ForegroundColor White
    kubectl get pods -n $namespace -l app=$service
    
    # Ver eventos recientes
    Write-Host "`nEventos recientes:" -ForegroundColor White
    kubectl get events -n $namespace --field-selector involvedObject.name=$service --sort-by='.lastTimestamp' | Select-Object -Last 5
    
    # Ver describe del deployment
    Write-Host "`nDescribe deployment:" -ForegroundColor White
    kubectl describe deployment $service -n $namespace | Select-String -Pattern "Conditions|Replicas|StrategyType|OldReplicaSets|NewReplicaSet"
    
    Write-Host "`n" -ForegroundColor White
}

Write-Host ""
Write-Host "Opciones de solucion:" -ForegroundColor Yellow
Write-Host "1. Reiniciar deployment: kubectl rollout restart deployment/<service> -n $namespace" -ForegroundColor White
Write-Host "2. Eliminar pods problematicos: kubectl delete pod <pod-name> -n $namespace" -ForegroundColor White
Write-Host "3. Aumentar progressDeadlineSeconds en el deployment YAML" -ForegroundColor White
Write-Host "4. Verificar recursos disponibles en el cluster" -ForegroundColor White
Write-Host ""

$fix = Read-Host "Deseas reiniciar los deployments problematicos? (S/N)"

if ($fix -eq 'S' -or $fix -eq 's') {
    Write-Host ""
    Write-Host "Reiniciando deployments..." -ForegroundColor Cyan
    
    foreach ($service in $services) {
        Write-Host "Reiniciando $service..." -ForegroundColor Yellow
        kubectl rollout restart deployment/$service -n $namespace
        Start-Sleep -Seconds 2
    }
    
    Write-Host ""
    Write-Host "Deployments reiniciados. Espera unos minutos y verifica el estado." -ForegroundColor Green
}
