# Script para agregar autenticacion Docker en todos los Jenkinsfiles

$services = @("user-service", "product-service", "order-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    Write-Host "Actualizando $service..." -ForegroundColor Yellow
    
    $file = "$service/Jenkinsfile"
    $content = Get-Content $file -Raw
    
    # Reemplazar el sh block del Pull Image stage
    $content = $content -replace `
        '(stage\(''Pull Image from Dev''\).*?sh """\s+echo "Pulling imagen:)', `
        '$1. /root/google-cloud-sdk/path.bash.inc
                        
                        # Autenticar Docker con GCP Artifact Registry
                        echo "Autenticando Docker con GCP..."
                        gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
                        
                        echo "Pulling imagen:'
    
    Set-Content $file -Value $content -NoNewline
    Write-Host "  $service actualizado" -ForegroundColor Green
}

Write-Host "Completado" -ForegroundColor Green
