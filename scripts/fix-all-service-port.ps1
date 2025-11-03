# Script simple para escapar SERVICE_PORT

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "favourite-service"
)

$jenkinsfiles = @(
    "Jenkinsfile",
    "Jenkinsfile.master"
)

foreach ($service in $services) {
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        
        if (Test-Path $filePath) {
            Write-Host "Procesando $filePath..."
            
            $content = Get-Content $filePath -Raw
            $content = $content -replace '"\\\$EXTERNAL_IP:\$\{SERVICE_PORT\}"', '"\$EXTERNAL_IP:\${SERVICE_PORT}"'
            $content | Set-Content $filePath -NoNewline
            
            Write-Host "  OK"
        }
    }
}

Write-Host "Completado"
