$files = Get-ChildItem "k8s\infrastructure\*.yaml"

foreach ($file in $files) {
    Write-Host "Actualizando $($file.Name)..." -ForegroundColor Cyan
    $content = Get-Content $file.FullName -Raw
    
    $content = $content -replace "initialDelaySeconds: 60", "initialDelaySeconds: 180"
    $content = $content -replace "initialDelaySeconds: 40", "initialDelaySeconds: 120"
    $content = $content -replace "periodSeconds: 10", "periodSeconds: 30"
    $content = $content -replace "timeoutSeconds: 5", "timeoutSeconds: 10"
    $content = $content -replace "failureThreshold: 3", "failureThreshold: 5"
    
    $content | Set-Content $file.FullName -NoNewline
    Write-Host "  OK" -ForegroundColor Green
}

Write-Host "Infraestructura actualizada" -ForegroundColor Green
