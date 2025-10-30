# Script para revertir Jenkinsfiles.dev a usar Minikube

Write-Host "Revirtiendo Jenkinsfiles.dev para usar Minikube..." -ForegroundColor Cyan
Write-Host ""

$services = @(
    'user-service',
    'product-service',
    'order-service',
    'payment-service',
    'favourite-service',
    'shipping-service'
)

$updatedFiles = 0

foreach ($service in $services) {
    $filePath = "$service/Jenkinsfile.dev"
    
    if (Test-Path $filePath) {
        Write-Host "Procesando $service..." -ForegroundColor Green
        
        $content = Get-Content $filePath -Raw
        
        # Revertir GKE a Minikube
        $content = $content -replace "# GKE Configuration", "# Minikube Configuration"
        $content = $content -replace "Deploy to GKE Dev", "Deploy to Minikube"
        $content = $content -replace "Desplegando .* en GKE Dev", "Desplegando `${SERVICE_NAME} en Minikube"
        $content = $content -replace "está corriendo correctamente en GKE Dev", "está corriendo correctamente en Minikube"
        
        # Remover configuración de GKE
        $content = $content -replace "PATH = ""/root/google-cloud-sdk/bin:`\$\{JAVA_HOME\}/bin:`\$\{env.PATH\}""", "PATH = ""`${JAVA_HOME}/bin:`${env.PATH}"""
        
        # Remover variable de GKE
        $content = $content -replace "USE_GKE_GCLOUD_AUTH_PLUGIN = 'True'`n        ", ""
        
        # Remover source de gcloud
        $content = $content -replace "\. /root/google-cloud-sdk/path\.bash\.inc`n                        `n                        ", ""
        
        $content | Out-File -FilePath $filePath -Encoding UTF8 -NoNewline
        
        Write-Host "  OK $service revertido a Minikube" -ForegroundColor Green
        $updatedFiles++
    } else {
        Write-Host "  ERROR $filePath no existe" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Archivos revertidos: $updatedFiles" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion de ambientes:" -ForegroundColor Yellow
Write-Host "  - DEV: Minikube (local)" -ForegroundColor White
Write-Host "  - STAGING: GKE namespace 'ecommerce-staging'" -ForegroundColor White
Write-Host "  - MASTER: GKE namespace 'ecommerce-prod'" -ForegroundColor White
Write-Host ""
Write-Host "Proximo paso: Instalar Minikube" -ForegroundColor Yellow
Write-Host ""
