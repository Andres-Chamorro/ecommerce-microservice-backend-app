# Script para actualizar el stage de Deploy - Enfoque simple
Write-Host "Actualizando stage de Deploy en todos los Jenkinsfiles..." -ForegroundColor Green

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
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar todo el contenido del stage Deploy
        $pattern = "(?s)(stage\('Deploy to Minikube'\)\s*\{[^}]*when\s*\{[^}]*\}[^}]*steps\s*\{[^}]*script\s*\{[^}]*echo[^\n]*\n)(.*?)(\s*\}\s*\}\s*\}\s*\})"
        
        $replacement = '$1                    // Desplegar usando kubectl desde el host Windows
                    bat """
                        REM Actualizar imagen en deployment
                        powershell -Command "(Get-Content ' + $service + '/k8s/deployment.yaml) -replace ''image:.*'', ''image: %IMAGE_NAME%:dev-%BUILD_TAG%'' | Set-Content ' + $service + '/k8s/deployment.yaml"
                        
                        REM Aplicar deployment
                        kubectl apply -f ' + $service + '/k8s/deployment.yaml
                        kubectl apply -f ' + $service + '/k8s/service.yaml
                        
                        REM Verificar deployment
                        kubectl rollout status deployment/%SERVICE_NAME% -n default --timeout=2m
                        kubectl get pods -n default -l app=%SERVICE_NAME%
                    """
$3'
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $content | Set-Content $jenkinsfile -NoNewline -Encoding UTF8
            Write-Host "Actualizado $jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "Patron no encontrado en $jenkinsfile, intentando enfoque alternativo..." -ForegroundColor Yellow
        }
    }
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
