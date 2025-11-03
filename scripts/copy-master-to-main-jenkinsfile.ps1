# Script para copiar Jenkinsfile.master a Jenkinsfile principal en cada servicio

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

Write-Host "Copiando Jenkinsfile.master a Jenkinsfile principal..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($service in $services) {
    $masterFile = "$service/Jenkinsfile.master"
    $mainFile = "$service/Jenkinsfile"
    
    Write-Host "Procesando $service..." -ForegroundColor Yellow
    
    if (Test-Path $masterFile) {
        try {
            Copy-Item -Path $masterFile -Destination $mainFile -Force
            Write-Host "   OK: $mainFile actualizado desde Jenkinsfile.master" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Host "   ERROR copiando archivo: $_" -ForegroundColor Red
            $errorCount++
        }
    }
    else {
        Write-Host "   No se encontro $masterFile" -ForegroundColor Yellow
        $errorCount++
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resumen:" -ForegroundColor Cyan
Write-Host "   Exitosos: $successCount" -ForegroundColor Green
Write-Host "   Errores: $errorCount" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($successCount -eq $services.Count) {
    Write-Host "Todos los Jenkinsfiles principales actualizados con pipeline de MASTER!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Archivos actualizados:" -ForegroundColor Cyan
    foreach ($service in $services) {
        Write-Host "   $service/Jenkinsfile" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Ahora cuando Jenkins ejecute en rama master, usara el pipeline de PRODUCCION" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pipeline de MASTER incluye:" -ForegroundColor Cyan
    Write-Host "   Pull Image from Staging" -ForegroundColor White
    Write-Host "   Semantic Versioning (v1.0.0)" -ForegroundColor White
    Write-Host "   Deploy to GKE Production" -ForegroundColor White
    Write-Host "   Smoke Tests" -ForegroundColor White
    Write-Host "   Verify Production" -ForegroundColor White
    Write-Host "   Generate Release Notes" -ForegroundColor White
    Write-Host "   Create Git Tags" -ForegroundColor White
}
else {
    Write-Host "Algunos archivos no se pudieron actualizar" -ForegroundColor Yellow
}
