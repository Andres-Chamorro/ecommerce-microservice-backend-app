# Script para arreglar la carga de imágenes en minikube desde Jenkins

Write-Host "Actualizando Jenkinsfiles para usar docker save optimizado..." -ForegroundColor Green

$services = @('user-service', 'shipping-service', 'product-service', 'payment-service', 'order-service', 'favourite-service')

foreach ($service in $services) {
    $file = "$service/Jenkinsfile"
    $content = Get-Content $file -Raw
    
    # Reemplazar minikube image load por docker save + docker load en minikube
    $content = $content -replace 'export MINIKUBE_HOME=/var/jenkins_home/\.minikube && minikube image load \$\{IMAGE_NAME\}:dev-\$\{BUILD_TAG\}', 'docker save ${IMAGE_NAME}:dev-${BUILD_TAG} | docker exec -i minikube docker load'
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText("$PWD\$file", $content, $utf8NoBom)
    
    Write-Host "✓ Actualizado $file"
}

Write-Host "`n✓ Todos los Jenkinsfiles actualizados!" -ForegroundColor Green
Write-Host "Ahora usa: docker save | docker exec -i minikube docker load" -ForegroundColor Cyan
