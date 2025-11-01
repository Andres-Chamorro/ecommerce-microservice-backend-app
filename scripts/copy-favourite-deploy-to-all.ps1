Write-Host "Copiando enfoque de deployment de favourite-service a todos los servicios..." -ForegroundColor Cyan

# Leer el Jenkinsfile de favourite-service como template
$template = Get-Content "favourite-service/Jenkinsfile" -Raw

$services = @(
    @{name="user-service"; port="8300"},
    @{name="order-service"; port="8100"},
    @{name="product-service"; port="8200"},
    @{name="payment-service"; port="8400"},
    @{name="shipping-service"; port="8500"}
)

foreach ($service in $services) {
    $serviceName = $service.name
    $servicePort = $service.port
    
    Write-Host "Actualizando $serviceName..." -ForegroundColor Yellow
    
    # Reemplazar valores especificos del servicio
    $content = $template -replace "SERVICE_NAME = 'favourite-service'", "SERVICE_NAME = '$serviceName'"
    $content = $content -replace "SERVICE_PORT = '8600'", "SERVICE_PORT = '$servicePort'"
    $content = $content -replace "dir\('favourite-service'\)", "dir('$serviceName')"
    $content = $content -replace "-f favourite-service/Dockerfile", "-f $serviceName/Dockerfile"
    $content = $content -replace "testResults: 'favourite-service/target", "testResults: '$serviceName/target"
    
    # Guardar el archivo
    $content | Set-Content "$serviceName/Jenkinsfile" -NoNewline
    
    Write-Host "OK $serviceName/Jenkinsfile actualizado" -ForegroundColor Green
}

Write-Host "`nTodos los Jenkinsfiles actualizados con deployment via pipe" -ForegroundColor Green
