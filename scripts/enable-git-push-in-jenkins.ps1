# Script para habilitar push de tags desde Jenkins a GitHub

Write-Host "🔧 Habilitando push de tags desde Jenkins..." -ForegroundColor Cyan
Write-Host ""

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

Write-Host "📝 Este script descomentará la línea de git push en todos los Jenkinsfile.master" -ForegroundColor Yellow
Write-Host ""

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile.master"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📄 Procesando: $jenkinsfile" -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Descomentar la línea de git push
        $content = $content -replace '# git push origin', 'git push origin'
        
        # Guardar cambios
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "  ✅ Habilitado git push en $service" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  No se encontró: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Proceso completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Configurar credenciales de Git en Jenkins" -ForegroundColor White
Write-Host "  2. Ejecutar un pipeline MASTER" -ForegroundColor White
Write-Host "  3. Verificar que se crea el tag en GitHub" -ForegroundColor White
Write-Host "  4. Verificar que GitHub Actions genera el release" -ForegroundColor White
Write-Host ""
Write-Host "🔐 Configurar credenciales en Jenkins:" -ForegroundColor Yellow
Write-Host "  Opción 1 - Personal Access Token:" -ForegroundColor White
Write-Host "    1. GitHub → Settings → Developer settings → Personal access tokens" -ForegroundColor Gray
Write-Host "    2. Generate new token (classic)" -ForegroundColor Gray
Write-Host "    3. Scope: repo (full control)" -ForegroundColor Gray
Write-Host "    4. Jenkins → Credentials → Add → Username with password" -ForegroundColor Gray
Write-Host "       Username: tu-usuario-github" -ForegroundColor Gray
Write-Host "       Password: el-token-generado" -ForegroundColor Gray
Write-Host ""
Write-Host "  Opción 2 - SSH Key:" -ForegroundColor White
Write-Host "    1. Generar SSH key: ssh-keygen -t ed25519 -C 'jenkins@ecommerce.com'" -ForegroundColor Gray
Write-Host "    2. Agregar public key a GitHub → Settings → SSH keys" -ForegroundColor Gray
Write-Host "    3. Jenkins → Credentials → Add → SSH Username with private key" -ForegroundColor Gray
