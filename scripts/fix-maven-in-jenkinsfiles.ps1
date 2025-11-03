Write-Host "Actualizando Jenkinsfiles para usar Maven con Docker agent..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        $newAgent = "agent {`n        docker {`n            image 'maven:3.9-eclipse-temurin-17'`n            args '-v /var/run/docker.sock:/var/run/docker.sock -v maven-repo:/root/.m2 --network host'`n            reuseNode true`n        }`n    }"
        $content = $content -replace 'agent any', $newAgent
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    } else {
        Write-Host "NO ENCONTRADO $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host "`nTodos los Jenkinsfiles actualizados para usar Maven" -ForegroundColor Green
