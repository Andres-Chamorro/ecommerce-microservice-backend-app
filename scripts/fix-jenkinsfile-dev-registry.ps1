# Script para actualizar Jenkinsfiles.dev para usar registry local de Minikube

$services = @('user-service', 'product-service', 'order-service', 'payment-service', 'favourite-service', 'shipping-service')

foreach ($service in $services) {
    $file = "$service/Jenkinsfile.dev"
    Write-Host "Actualizando $file..."
    
    # Leer contenido
    $content = Get-Content $file -Raw -Encoding UTF8
    
    # Reemplazar la configuración del registry
    $content = $content -replace "DOCKER_REGISTRY = 'us-central1-docker\.pkg\.dev/ecommerce-microservices-476519/ecommerce-registry'[^\n]*\n\s*IMAGE_NAME = ""\$\{DOCKER_REGISTRY\}/\$\{SERVICE_NAME\}""", "IMAGE_NAME = ""`${SERVICE_NAME}"""
    
    # Eliminar la línea de Push to Registry ya que no la necesitamos en local
    $content = $content -replace "stage\('Push to Registry'\)[^}]*\{[^}]*docker push[^}]*\}[^}]*\}", ""
    
    # Guardar sin BOM
    [System.IO.File]::WriteAllText("$PWD\$file", $content, [System.Text.UTF8Encoding]::new($false))
    
    Write-Host "✓ $file actualizado"
}

Write-Host "`n✅ Todos los Jenkinsfile.dev actualizados para usar registry local"
