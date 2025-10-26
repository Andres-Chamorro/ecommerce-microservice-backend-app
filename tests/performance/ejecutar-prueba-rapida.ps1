# Script para ejecutar una prueba rápida de Locust
# Genera un reporte HTML con los resultados

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ejecutando Prueba de Rendimiento Rápida" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  - Usuarios: 20" -ForegroundColor White
Write-Host "  - Spawn rate: 5 usuarios/segundo" -ForegroundColor White
Write-Host "  - Duración: 1 minuto" -ForegroundColor White
Write-Host "  - Host: http://localhost:8080" -ForegroundColor White
Write-Host ""

Write-Host "Iniciando prueba..." -ForegroundColor Green
Write-Host ""

# Ejecutar Locust en modo headless
locust -f locustfile.py `
    --host=http://localhost:8080 `
    --headless `
    --users 20 `
    --spawn-rate 5 `
    --run-time 1m `
    --html reporte_locust.html `
    --csv reporte_locust

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Prueba Completada!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Reportes generados:" -ForegroundColor Yellow
Write-Host "  - reporte_locust.html (Reporte visual)" -ForegroundColor White
Write-Host "  - reporte_locust_stats.csv (Estadísticas)" -ForegroundColor White
Write-Host "  - reporte_locust_failures.csv (Errores)" -ForegroundColor White
Write-Host ""
Write-Host "Para ver el reporte HTML:" -ForegroundColor Yellow
Write-Host "  Invoke-Item reporte_locust.html" -ForegroundColor White
Write-Host ""
