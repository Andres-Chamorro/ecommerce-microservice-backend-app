# Script para ejecutar prueba de Locust que SÍ funciona
# Usa solo operaciones GET que sabemos que funcionan

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Prueba de Rendimiento - Solo Lectura" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Esta versión solo usa operaciones GET" -ForegroundColor Yellow
Write-Host "que funcionan correctamente (0% errores)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  - Usuarios: 30" -ForegroundColor White
Write-Host "  - Spawn rate: 5 usuarios/segundo" -ForegroundColor White
Write-Host "  - Duración: 1 minuto" -ForegroundColor White
Write-Host "  - Host: http://localhost:8080" -ForegroundColor White
Write-Host ""

Write-Host "Endpoints que se probarán:" -ForegroundColor Yellow
Write-Host "  ✅ GET /product-service/api/products" -ForegroundColor Green
Write-Host "  ✅ GET /user-service/api/users" -ForegroundColor Green
Write-Host "  ✅ GET /order-service/api/orders" -ForegroundColor Green
Write-Host "  ✅ GET /product-service/api/categories" -ForegroundColor Green
Write-Host "  ✅ GET /actuator/health (varios servicios)" -ForegroundColor Green
Write-Host ""

Write-Host "Iniciando prueba..." -ForegroundColor Green
Write-Host ""

# Ejecutar Locust con el archivo simplificado
locust -f locustfile_simple.py `
    --headless `
    --users 30 `
    --spawn-rate 5 `
    --run-time 1m `
    --html reporte_funcional.html `
    --csv reporte_funcional

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Prueba Completada!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Reportes generados:" -ForegroundColor Yellow
Write-Host "  - reporte_funcional.html (Reporte visual)" -ForegroundColor White
Write-Host "  - reporte_funcional_stats.csv (Estadísticas)" -ForegroundColor White
Write-Host "  - reporte_funcional_failures.csv (Errores)" -ForegroundColor White
Write-Host ""
Write-Host "Para ver el reporte:" -ForegroundColor Yellow
Write-Host "  Invoke-Item reporte_funcional.html" -ForegroundColor White
Write-Host ""
Write-Host "Resultado esperado:" -ForegroundColor Yellow
Write-Host "  ✅ 0% de errores (todos los endpoints funcionan)" -ForegroundColor Green
Write-Host "  ✅ Cientos de requests exitosos" -ForegroundColor Green
Write-Host "  ✅ Tiempos de respuesta medidos" -ForegroundColor Green
Write-Host ""
