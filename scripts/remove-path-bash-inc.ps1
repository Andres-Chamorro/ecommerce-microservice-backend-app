# Script para eliminar las líneas problemáticas de path.bash.inc de los Jenkinsfiles

$services = @(
    "order-service",
    "product-service",
    "user-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Eliminar las líneas ". /root/google-cloud-sdk/path.bash.inc"
        $content = $content -replace '\s*\. /root/google-cloud-sdk/path\.bash\.inc\s*\n', ''
        
        # Limpiar líneas vacías múltiples
        $content = $content -replace '\n\s*\n\s*\n', "`n`n"
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "✅ $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`n✅ Todos los Jenkinsfiles han sido actualizados" -ForegroundColor Green
Write-Host "Las líneas de path.bash.inc han sido eliminadas porque gcloud ya está en el PATH" -ForegroundColor Yellow
