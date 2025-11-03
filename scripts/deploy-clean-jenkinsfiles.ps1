Write-Host "Desplegando Jenkinsfiles limpios a todos los servicios..." -ForegroundColor Cyan

$services = @(
    @{name="order-service"; port="8100"},
    @{name="product-service"; port="8200"},
    @{name="payment-service"; port="8400"},
    @{name="shipping-service"; port="8500"},
    @{name="favourite-service"; port="8600"}
)

# Leer el Jenkinsfile template de user-service
$template = Get-Content "user-service/Jenkinsfile.dev" -Raw

foreach ($service in $services) {
    $serviceName = $service.name
    $servicePort = $service.port
    
    Write-Host "Creando Jenkinsfile.dev para $serviceName..." -ForegroundColor Yellow
    
    # Reemplazar valores especificos del servicio
    $content = $template -replace "SERVICE_NAME = 'user-service'", "SERVICE_NAME = '$serviceName'"
    $content = $content -replace "SERVICE_PORT = '8300'", "SERVICE_PORT = '$servicePort'"
    $content = $content -replace "dir\('user-service'\)", "dir('$serviceName')"
    $content = $content -replace "-f user-service/Dockerfile", "-f $serviceName/Dockerfile"
    $content = $content -replace "testResults: 'user-service/target", "testResults: '$serviceName/target"
    
    # Guardar el archivo
    $content | Set-Content "$serviceName/Jenkinsfile.dev" -NoNewline
    
    Write-Host "OK $serviceName/Jenkinsfile.dev creado" -ForegroundColor Green
}

Write-Host "`nTodos los Jenkinsfiles desplegados correctamente" -ForegroundColor Green
Write-Host "Los Jenkinsfiles ahora usan:" -ForegroundColor Cyan
Write-Host "  - Maven instalado en Jenkins" -ForegroundColor White
Write-Host "  - docker exec minikube kubectl para comandos de Kubernetes" -ForegroundColor White
Write-Host "  - Archivos temporales para deployments" -ForegroundColor White
