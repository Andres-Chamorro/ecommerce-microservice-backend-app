# Script para arreglar la instalacion de Locust usando virtual environment

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

$oldInstallBlock = @'
                            # Instalar locust si no está instalado
                            pip3 install locust || echo "Locust ya instalado"
'@

$newInstallBlock = @'
                            # Crear virtual environment e instalar locust
                            python3 -m venv /tmp/locust-venv || true
                            . /tmp/locust-venv/bin/activate
                            pip3 install locust || echo "Error instalando Locust"
'@

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.staging"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..."
        
        $content = Get-Content $jenkinsfile -Raw
        $content = $content -replace [regex]::Escape($oldInstallBlock), $newInstallBlock
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "Actualizado $jenkinsfile"
    } else {
        Write-Host "No se encontro $jenkinsfile"
    }
}

Write-Host ""
Write-Host "Todos los Jenkinsfiles actualizados"
