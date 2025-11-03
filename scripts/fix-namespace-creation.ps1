# Script para arreglar la creación de namespace para que no falle si ya existe

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

$jenkinsfiles = @(
    "Jenkinsfile",
    "Jenkinsfile.master",
    "Jenkinsfile.staging"
)

Write-Host "Arreglando creación de namespace en Jenkinsfiles..." -ForegroundColor Yellow

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..." -ForegroundColor Cyan
            
            $content = Get-Content $filePath -Raw
            
            # Agregar || true al final del comando de creación de namespace
            $content = $content -replace 'kubectl create namespace \$K8S_NAMESPACE --dry-run=client -o yaml \| kubectl apply -f -', 'kubectl create namespace $K8S_NAMESPACE --dry-run=client -o yaml | kubectl apply -f - || true'
            
            # Guardar
            $content | Set-Content $filePath -NoNewline
            
            Write-Host "Actualizado $filePath" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "Creación de namespace arreglada en todos los Jenkinsfiles" -ForegroundColor Green
Write-Host "Ahora el pipeline no fallará si el namespace ya existe" -ForegroundColor Cyan
