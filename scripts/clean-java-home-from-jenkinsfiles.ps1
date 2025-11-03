Write-Host "Limpiando JAVA_HOME innecesario de Jenkinsfiles..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Limpiando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        $content = $content -replace '        // Java Configuration\r?\n        JAVA_HOME = ''/usr/lib/jvm/java-17-openjdk-amd64''\r?\n        PATH = "\$\{JAVA_HOME\}/bin:\$\{env\.PATH\}"\r?\n        \r?\n', ''
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile limpiado" -ForegroundColor Green
    }
}

Write-Host "`nJAVA_HOME removido de todos los Jenkinsfiles" -ForegroundColor Green
