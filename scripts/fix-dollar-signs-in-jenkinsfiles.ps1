# Script para escapar correctamente los $ en los Jenkinsfiles

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
    "Jenkinsfile.master"
)

Write-Host "Arreglando signos de dolar en Jenkinsfiles..." -ForegroundColor Yellow

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..." -ForegroundColor Cyan
            
            $content = Get-Content $filePath -Raw
            
            # Arreglar las variables que no están escapadas correctamente
            # Estas están dentro de bloques sh """ """ y deben tener \$ en lugar de $
            
            # Arreglar SERVICE_PORT sin escapar
            $content = $content -replace 'svc/\$\{SERVICE_NAME\} 8080:\$\{SERVICE_PORT\}', 'svc/${SERVICE_NAME} 8080:${SERVICE_PORT}'
            $content = $content -replace 'svc/\$\{SERVICE_NAME\} 8080:\$\{SERVICE_PORT\}', 'svc/$SERVICE_NAME 8080:$SERVICE_PORT'
            
            # Cambiar a usar variables bash simples en lugar de ${VAR}
            $content = $content -replace 'kubectl port-forward svc/\$\{SERVICE_NAME\} 8080:\$\{SERVICE_PORT\} -n \$\{K8S_NAMESPACE\}', 'kubectl port-forward svc/$SERVICE_NAME 8080:$SERVICE_PORT -n $K8S_NAMESPACE'
            
            # Arreglar SERVICE_PORT en la asignación de SERVICE_URL
            $content = $content -replace 'SERVICE_URL="\\$EXTERNAL_IP:\\$\{SERVICE_PORT\}"', 'SERVICE_URL="$EXTERNAL_IP:$SERVICE_PORT"'
            
            # Guardar el archivo
            $content | Set-Content $filePath -NoNewline
            
            Write-Host "Actualizado $filePath" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "Signos de dolar corregidos en todos los Jenkinsfiles" -ForegroundColor Green
