# Script para actualizar Jenkinsfiles.dev para usar GKE en lugar de Minikube

Write-Host "Actualizando Jenkinsfiles.dev para usar GKE..." -ForegroundColor Cyan
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
        
        # Reemplazar Minikube por GKE
        $content = $content -replace "# Minikube Configuration", "# GKE Configuration"
        $content = $content -replace "Deploy to Minikube", "Deploy to GKE Dev"
        $content = $content -replace "Desplegando .* en Minikube", "Desplegando `${SERVICE_NAME} en GKE Dev"
        $content = $content -replace "está corriendo correctamente en Minikube", "está corriendo correctamente en GKE Dev"
        
        # Agregar configuración de GKE
        $content = $content -replace "PATH = ""`\$\{JAVA_HOME\}/bin:`\$\{env.PATH\}""", "PATH = ""/root/google-cloud-sdk/bin:`${JAVA_HOME}/bin:`${env.PATH}"""
        
        # Agregar variable de GKE
        if ($content -notmatch "USE_GKE_GCLOUD_AUTH_PLUGIN") {
            $content = $content -replace "(K8S_NAMESPACE = 'ecommerce-dev')", "USE_GKE_GCLOUD_AUTH_PLUGIN = 'True'`n        K8S_NAMESPACE = 'ecommerce-dev'"
        }
        
        # Agregar source de gcloud en los comandos kubectl
        $content = $content -replace "kubectl create namespace", ". /root/google-cloud-sdk/path.bash.inc`n                        `n                        kubectl create namespace"
        
        $content | Out-File -FilePath $filePath -Encoding UTF8 -NoNewline
        
        Write-Host "  OK $service actualizado" -ForegroundColor Green
        $updatedFiles++
    } else {
        Write-Host "  ERROR $filePath no existe" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Archivos actualizados: $updatedFiles" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ahora todos los ambientes usan GKE:" -ForegroundColor Yellow
Write-Host "  - DEV: GKE namespace 'ecommerce-dev'" -ForegroundColor White
Write-Host "  - STAGING: GKE namespace 'ecommerce-staging'" -ForegroundColor White
Write-Host "  - MASTER: GKE namespace 'ecommerce-prod'" -ForegroundColor White
Write-Host ""
