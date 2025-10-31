# Script para actualizar Jenkinsfiles.staging basados en la configuración exitosa de dev

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Actualizando Jenkinsfiles.staging para usar Minikube..." -ForegroundColor Cyan

foreach ($service in $services) {
    $devFile = "$service/Jenkinsfile.dev"
    $stagingFile = "$service/Jenkinsfile.staging"
    
    if (Test-Path $devFile) {
        Write-Host "`nActualizando $stagingFile..." -ForegroundColor Yellow
        
        # Leer el Jenkinsfile.dev exitoso
        $bytes = [System.IO.File]::ReadAllBytes($devFile)
        $content = [System.Text.Encoding]::UTF8.GetString($bytes)
        
        # Hacer los cambios para staging:
        # 1. Cambiar namespace de ecommerce-dev a ecommerce-staging
        $content = $content -replace 'ecommerce-dev', 'ecommerce-staging'
        
        # 2. Cambiar tags de dev- a staging-
        $content = $content -replace ':dev-', ':staging-'
        $content = $content -replace 'dev-latest', 'staging-latest'
        
        # 3. Cambiar mensajes de [DEV] a [STAGING]
        $content = $content -replace '\[DEV\]', '[STAGING]'
        
        # 4. Cambiar "Pipeline DEV" a "Pipeline STAGING"
        $content = $content -replace 'Pipeline DEV', 'Pipeline STAGING'
        $content = $content -replace 'Ambiente: Minikube \(Local\)', 'Ambiente: Minikube (Staging)'
        
        # Guardar sin BOM
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($stagingFile, $content, $utf8NoBom)
        
        Write-Host "  Actualizado!" -ForegroundColor Green
    } else {
        Write-Host "  No encontrado: $devFile" -ForegroundColor Red
    }
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
Write-Host "Cambios aplicados:" -ForegroundColor White
Write-Host "  - Namespace: ecommerce-staging" -ForegroundColor White
Write-Host "  - Tags: staging-X" -ForegroundColor White
Write-Host "  - Misma estrategia de docker save | docker load" -ForegroundColor White
