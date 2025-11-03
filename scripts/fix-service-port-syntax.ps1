# Script para corregir sintaxis de SERVICE_PORT en Jenkinsfiles

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

Write-Host "Corrigiendo sintaxis de SERVICE_PORT en Jenkinsfiles..." -ForegroundColor Yellow

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..." -ForegroundColor Cyan
            
            $content = Get-Content $filePath -Raw
            
            # Reemplazar todas las ocurrencias de ${SERVICE_PORT} con \${SERVICE_PORT}
            # Esto asegura que Groovy no intente interpolar la variable
            $oldPattern = '"\$EXTERNAL_IP:\$\{SERVICE_PORT\}"'
            $newPattern = '"\$EXTERNAL_IP:\${SERVICE_PORT}"'
            
            if ($content -match [regex]::Escape($oldPattern)) {
                $content = $content -replace [regex]::Escape($oldPattern), $newPattern
                $content | Set-Content $filePath -NoNewline
                Write-Host "  Actualizado $filePath" -ForegroundColor Green
            } else {
                Write-Host "  No se encontro patron en $filePath" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
Write-Host "Sintaxis de SERVICE_PORT corregida" -ForegroundColor Green
