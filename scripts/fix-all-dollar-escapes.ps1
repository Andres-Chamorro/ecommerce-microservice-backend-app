# Script para arreglar TODOS los escapes de $ en Jenkinsfiles

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

$jenkinsfiles = @(
    "Jenkinsfile",
    "Jenkinsfile.master",
    "Jenkinsfile.staging"
)

Write-Host "Arreglando TODOS los escapes de dolar en Jenkinsfiles..." -ForegroundColor Yellow

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..." -ForegroundColor Cyan
            
            $content = Get-Content $filePath -Raw
            
            # Arreglar SERVICE_URL="\$EXTERNAL_IP:\${SERVICE_PORT}"
            # Cambiar a usar $SERVICE_PORT sin llaves
            $content = $content -replace 'SERVICE_URL="\\$EXTERNAL_IP:\\$\{SERVICE_PORT\}"', 'SERVICE_URL="$EXTERNAL_IP:$SERVICE_PORT"'
            
            # Arreglar kubectl port-forward con ${K8S_NAMESPACE}
            $content = $content -replace '\$\{K8S_NAMESPACE\}', '$K8S_NAMESPACE'
            
            # Guardar el archivo
            $content | Set-Content $filePath -NoNewline
            
            Write-Host "Actualizado $filePath" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "Todos los escapes de dolar corregidos" -ForegroundColor Green
