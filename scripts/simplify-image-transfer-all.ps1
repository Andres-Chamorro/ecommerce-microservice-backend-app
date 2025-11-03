Write-Host "Simplificando transferencia de imagenes en todos los Jenkinsfiles..." -ForegroundColor Cyan

$services = @(
    @{name="user-service"; dir="user-service"},
    @{name="order-service"; dir="order-service"},
    @{name="product-service"; dir="product-service"},
    @{name="payment-service"; dir="payment-service"},
    @{name="shipping-service"; dir="shipping-service"}
)

foreach ($service in $services) {
    $serviceName = $service.name
    $serviceDir = $service.dir
    $jenkinsfile = "$serviceDir/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar todo el bloque de transferencia con el metodo simple
        $content = $content -replace '# Guardar imagen a archivo tar[\s\S]*?# Verificar que la imagen existe en Minikube', @"
# Transferir imagen directamente a Minikube usando pipe
                        docker save `${IMAGE_NAME}:dev-`${BUILD_TAG} | docker exec -i minikube ctr -n k8s.io images import -
                        
                        # Verificar que la imagen existe en Minikube
"@
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles simplificados" -ForegroundColor Green
