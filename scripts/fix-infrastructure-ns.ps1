$files = Get-ChildItem "k8s\infrastructure\*.yaml"

foreach ($file in $files) {
    Write-Host "Actualizando $($file.Name)..." -ForegroundColor Cyan
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace "namespace: ecommerce-dev", "namespace: ecommerce-staging"
    $content | Set-Content $file.FullName -NoNewline
    Write-Host "  OK" -ForegroundColor Green
}

Write-Host "Infraestructura actualizada" -ForegroundColor Green
