# Script para limpiar workflows antiguos de GitHub Actions
# Estos workflows son del fork original y ahora Jenkins maneja todo el CI/CD

Write-Host "Limpiando workflows antiguos de GitHub Actions..." -ForegroundColor Cyan
Write-Host ""

$workflowsDir = ".github/workflows"

# Workflows a MANTENER (solo el nuevo de release notes)
$keepWorkflows = @(
    "release-notes.yml"
)

Write-Host "Workflows que se mantendran:" -ForegroundColor Green
foreach ($workflow in $keepWorkflows) {
    Write-Host "  $workflow" -ForegroundColor Green
}
Write-Host ""

# Obtener todos los workflows
$allWorkflows = Get-ChildItem -Path $workflowsDir -Filter "*.yml" -File

Write-Host "Workflows que se eliminaran:" -ForegroundColor Yellow
$toDelete = @()

foreach ($workflow in $allWorkflows) {
    if ($keepWorkflows -notcontains $workflow.Name) {
        Write-Host "  $($workflow.Name)" -ForegroundColor Yellow
        $toDelete += $workflow
    }
}

Write-Host ""
Write-Host "Total de workflows a eliminar: $($toDelete.Count)" -ForegroundColor Cyan
Write-Host ""

# Confirmar antes de eliminar
$confirmation = Read-Host "Deseas continuar con la eliminacion? (S/N)"

if ($confirmation -eq 'S' -or $confirmation -eq 's') {
    Write-Host ""
    Write-Host "Eliminando workflows..." -ForegroundColor Red
    
    foreach ($workflow in $toDelete) {
        try {
            Remove-Item -Path $workflow.FullName -Force
            Write-Host "  Eliminado: $($workflow.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "  Error al eliminar: $($workflow.Name)" -ForegroundColor Red
            Write-Host "     Error: $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Limpieza completada!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Resumen:" -ForegroundColor Cyan
    Write-Host "  - Workflows eliminados: $($toDelete.Count)" -ForegroundColor White
    Write-Host "  - Workflows mantenidos: $($keepWorkflows.Count)" -ForegroundColor White
    Write-Host ""
    Write-Host "Ahora solo tienes:" -ForegroundColor Cyan
    Write-Host "  - Jenkins: Maneja todo el CI/CD (DEV, STAGING, MASTER)" -ForegroundColor White
    Write-Host "  - GitHub Actions: Solo genera Release Notes cuando creas tags" -ForegroundColor White
}
else {
    Write-Host ""
    Write-Host "Operacion cancelada" -ForegroundColor Yellow
}
