# Script para agregar configuracion de kubectl GKE en todos los Jenkinsfiles

$services = @("user-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    Write-Host "Actualizando $service..." -ForegroundColor Yellow
    
    $file = "$service/Jenkinsfile"
    $content = Get-Content $file -Raw
    
    # Agregar gcloud container clusters get-credentials antes de kubectl
    $content = $content -replace `
        '(\. /root/google-cloud-sdk/path\.bash\.inc\s+# Crear namespace)', `
        '. /root/google-cloud-sdk/path.bash.inc
                        
                        # Configurar kubectl para GKE
                        gcloud container clusters get-credentials ecommerce-cluster --zone us-central1-c --project ecommerce-microservices-476519
                        
                        # Crear namespace'
    
    Set-Content $file -Value $content -NoNewline
    Write-Host "  $service actualizado" -ForegroundColor Green
}

Write-Host "Completado" -ForegroundColor Green
