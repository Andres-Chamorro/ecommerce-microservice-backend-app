# Script para arreglar el deployment en producción para que use el namespace correcto

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

Write-Host "Arreglando deployment de producción en Jenkinsfiles..." -ForegroundColor Yellow

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..." -ForegroundColor Cyan
            
            $content = Get-Content $filePath -Raw
            
            # Reemplazar el comando kubectl apply para que use sed y reemplace el namespace
            $oldPattern = 'kubectl apply -f k8s/microservices/\$\{SERVICE_NAME\}-deployment\.yaml -n \$K8S_NAMESPACE'
            $newPattern = 'sed "s/namespace: ecommerce-staging/namespace: $K8S_NAMESPACE/g" k8s/microservices/${SERVICE_NAME}-deployment.yaml | kubectl apply -f -'
            
            $content = $content -replace [regex]::Escape($oldPattern), $newPattern
            
            # Guardar
            $content | Set-Content $filePath -NoNewline
            
            Write-Host "Actualizado $filePath" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "Deployment de producción arreglado en todos los Jenkinsfiles" -ForegroundColor Green
Write-Host "Ahora usará sed para reemplazar el namespace antes de aplicar" -ForegroundColor Cyan
