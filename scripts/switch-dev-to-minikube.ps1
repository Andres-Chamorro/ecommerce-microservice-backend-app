# Script para cambiar referencias de GKE a Minikube en Jenkinsfiles de dev

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "🔄 Cambiando configuración de GKE a Minikube en rama dev..." -ForegroundColor Cyan
Write-Host ""

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📝 Procesando: $jenkinsfile"
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Cambiar referencias de GKE a Minikube
        $content = $content -replace 'gcloud container clusters get-credentials.*', 'kubectl config use-context minikube'
        $content = $content -replace 'USE_GKE_GCLOUD_AUTH_PLUGIN.*', '# Minikube no necesita GKE auth plugin'
        $content = $content -replace 'gcloud auth.*', '# Minikube usa contexto local'
        
        # Guardar cambios
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "  ✅ Actualizado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  No encontrado: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Configuración cambiada a Minikube exitosamente" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora los Jenkinsfiles usarán:" -ForegroundColor Cyan
Write-Host "  - kubectl config use-context minikube" -ForegroundColor White
Write-Host "  - Namespace: ecommerce-dev" -ForegroundColor White
