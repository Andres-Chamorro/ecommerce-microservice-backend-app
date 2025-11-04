# Script para eliminar BOM de todos los Jenkinsfiles

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "🧹 Limpiando BOM de Jenkinsfiles..." -ForegroundColor Cyan

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "  Procesando: $jenkinsfile"
        
        # Leer contenido sin BOM
        $content = Get-Content $jenkinsfile -Raw
        
        # Eliminar BOM si existe
        $content = $content -replace "^\xEF\xBB\xBF", ""
        $content = $content -replace "^", ""
        
        # Guardar sin BOM
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText((Resolve-Path $jenkinsfile), $content, $utf8NoBom)
        
        Write-Host "    ✅ Limpiado" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ Todos los Jenkinsfiles limpiados" -ForegroundColor Green
