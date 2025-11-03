# Script para crear Jenkinsfiles de MASTER/PRODUCTION para todos los servicios

$services = @(
    @{name="order-service"; port="8300"},
    @{name="payment-service"; port="8400"},
    @{name="product-service"; port="8500"},
    @{name="shipping-service"; port="8600"},
    @{name="favourite-service"; port="8800"}
)

$template = Get-Content "user-service/Jenkinsfile.master" -Raw

foreach ($service in $services) {
    $serviceName = $service.name
    $servicePort = $service.port
    
    Write-Host "Creando Jenkinsfile.master para $serviceName..."
    
    # Reemplazar valores específicos del servicio
    $content = $template -replace "SERVICE_NAME = 'user-service'", "SERVICE_NAME = '$serviceName'"
    $content = $content -replace "SERVICE_PORT = '8700'", "SERVICE_PORT = '$servicePort'"
    
    # Guardar archivo
    $outputPath = "$serviceName/Jenkinsfile.master"
    $content | Set-Content $outputPath -NoNewline
    
    Write-Host "✅ $outputPath creado"
}

Write-Host "`nTodos los Jenkinsfiles de MASTER/PRODUCTION creados"
Write-Host "Servicios configurados: order, payment, product, shipping, favourite"
Write-Host "Namespace: ecommerce-prod"
Write-Host "Versionado semantico: Habilitado"
