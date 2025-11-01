Write-Host "Revirtiendo Jenkinsfiles a usar agent any..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.dev"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        $content = $content -replace "agent \{\s+docker \{\s+image 'maven:3\.9-eclipse-temurin-17'\s+args '-v /var/run/docker\.sock:/var/run/docker\.sock -v maven-repo:/root/\.m2 --network host'\s+reuseNode true\s+\}\s+\}", "agent any"
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles revertidos a agent any" -ForegroundColor Green
