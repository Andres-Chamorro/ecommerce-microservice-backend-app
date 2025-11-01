# Script para configurar el deploy usando puerto 2376 de Minikube sin TLS
# Fecha: 2025-10-31

Write-Host "Configurando Jenkinsfiles para usar puerto 2376 de Minikube sin TLS..." -ForegroundColor Cyan

$services = @(
    "product-service",
    "user-service",
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

$oldPattern = 'kubectl config set-cluster minikube --server=https://192\.168\.67\.2:8443 --insecure-skip-tls-verify=true'
$newPattern = 'kubectl config set-cluster minikube --server=http://192.168.67.2:2376 --insecure-skip-tls-verify=true'

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw -Encoding UTF8
        
        # Reemplazar la configuración del servidor de Minikube
        $content = $content -replace $oldPattern, $newPattern
        
        # Guardar el archivo
        $content | Set-Content $jenkinsfile -Encoding UTF8 -NoNewline
        
        Write-Host "  OK $jenkinsfile actualizado" -ForegroundColor Green
    } else {
        Write-Host "  ERROR $jenkinsfile no encontrado" -ForegroundColor Red
    }
}

Write-Host "`nConfiguracion completada!" -ForegroundColor Green
Write-Host "`nAhora los Jenkinsfiles usaran:" -ForegroundColor Cyan
Write-Host "  - Servidor: http://192.168.67.2:2376" -ForegroundColor White
Write-Host "  - Sin TLS (inseguro pero funcional para desarrollo local)" -ForegroundColor Yellow
Write-Host "`nNOTA: Asegurate de que Minikube este exponiendo el puerto 2376" -ForegroundColor Magenta
