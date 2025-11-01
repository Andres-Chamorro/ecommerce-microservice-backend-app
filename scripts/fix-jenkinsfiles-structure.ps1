Write-Host "Arreglando estructura de Jenkinsfiles..." -ForegroundColor Cyan

# Copiar el Jenkinsfile de user-service (que ya está arreglado) a los demás servicios
$services = @(
    @{name="order-service"; port="8100"},
    @{name="product-service"; port="8200"},
    @{name="payment-service"; port="8400"},
    @{name="shipping-service"; port="8500"},
    @{name="favourite-service"; port="8600"}
)

$template = Get-Content "user-service/Jenkinsfile" -Raw

foreach ($service in $services) {
    $serviceName = $service.name
    $servicePort = $service.port
    
    Write-Host "Actualizando $serviceName..." -ForegroundColor Yellow
    
    # Reemplazar valores específicos del servicio
    $content = $template -replace "SERVICE_NAME = 'user-service'", "SERVICE_NAME = '$serviceName'"
    $content = $content -replace "SERVICE_PORT = '8300'", "SERVICE_PORT = '$servicePort'"
    $content = $content -replace "dir\('user-service'\)", "dir('$serviceName')"
    $content = $content -replace "-f user-service/Dockerfile", "-f $serviceName/Dockerfile"
    $content = $content -replace "testResults: 'user-service/target", "testResults: '$serviceName/target"
    $content = $content -replace "execPattern: 'user-service/target", "execPattern: '$serviceName/target"
    $content = $content -replace "classPattern: 'user-service/target", "classPattern: '$serviceName/target"
    $content = $content -replace "sourcePattern: 'user-service/src", "sourcePattern: '$serviceName/src"
    
    # Guardar el archivo
    $content | Set-Content "$serviceName/Jenkinsfile" -NoNewline
    
    Write-Host "OK $serviceName/Jenkinsfile actualizado" -ForegroundColor Green
}

Write-Host "`nTodos los Jenkinsfiles arreglados con reportes completos" -ForegroundColor Green
