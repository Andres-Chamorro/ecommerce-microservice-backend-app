# Script para corregir la verificacion de imagenes usando ctr en lugar de crictl
# El problema: ctr importa en namespace k8s.io pero crictl busca en otro namespace

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Corrigiendo verificacion de imagen en $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar crictl por ctr para verificacion
        if ($content -match 'crictl images') {
            $content = $content -replace 'docker exec minikube crictl images', 'docker exec minikube ctr -n k8s.io images ls'
            
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "  ✓ Corregido: Usando 'ctr -n k8s.io images ls' en lugar de 'crictl images'" -ForegroundColor Green
        } else {
            Write-Host "  - Ya usa ctr o no tiene verificacion" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✓ Correccion completada en todos los servicios" -ForegroundColor Green
Write-Host "`nAhora la verificacion usa el mismo namespace (k8s.io) que la importacion" -ForegroundColor Cyan
