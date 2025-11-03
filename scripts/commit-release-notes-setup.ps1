# Script para hacer commit de la configuración de release notes

Write-Host "📝 Preparando commit de configuración de Release Notes..." -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en un repositorio git
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: No estás en la raíz de un repositorio Git" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Archivos que se agregarán al commit:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ✅ .github/workflows/release-notes.yml" -ForegroundColor Green
Write-Host "  ✅ scripts/cleanup-old-workflows.ps1" -ForegroundColor Green
Write-Host "  ✅ scripts/enable-git-push-in-jenkins.ps1" -ForegroundColor Green
Write-Host "  ✅ scripts/commit-release-notes-setup.ps1" -ForegroundColor Green
Write-Host "  ✅ GITHUB_ACTIONS_RELEASE_NOTES.md" -ForegroundColor Green
Write-Host "  ✅ ESTRATEGIA_RELEASE_NOTES.md" -ForegroundColor Green
Write-Host ""

$confirmation = Read-Host "¿Deseas hacer commit de estos archivos? (S/N)"

if ($confirmation -eq 'S' -or $confirmation -eq 's') {
    Write-Host ""
    Write-Host "📦 Agregando archivos al staging..." -ForegroundColor Cyan
    
    git add .github/workflows/release-notes.yml
    git add scripts/cleanup-old-workflows.ps1
    git add scripts/enable-git-push-in-jenkins.ps1
    git add scripts/commit-release-notes-setup.ps1
    git add GITHUB_ACTIONS_RELEASE_NOTES.md
    git add ESTRATEGIA_RELEASE_NOTES.md
    
    Write-Host "✅ Archivos agregados" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "💾 Haciendo commit..." -ForegroundColor Cyan
    
    $commitMessage = @"
feat: Add GitHub Actions workflow for automated release notes

- Add release-notes.yml workflow triggered by Git tags
- Generate release notes with automatic changelog
- Publish to GitHub Releases for public visibility
- Add cleanup script for old workflows (60 files)
- Add script to enable Git push from Jenkins
- Add comprehensive documentation

This implements a multi-platform strategy:
- Jenkins: Handles CI/CD (build, test, deploy)
- GitHub Actions: Generates public release notes

Closes #release-notes-automation
"@
    
    git commit -m $commitMessage
    
    Write-Host "✅ Commit realizado" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "🚀 ¿Deseas hacer push al repositorio remoto? (S/N)" -ForegroundColor Yellow
    $pushConfirmation = Read-Host
    
    if ($pushConfirmation -eq 'S' -or $pushConfirmation -eq 's') {
        Write-Host ""
        Write-Host "📤 Haciendo push..." -ForegroundColor Cyan
        
        git push
        
        Write-Host "✅ Push completado" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 ¡Configuración de Release Notes subida exitosamente!" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "⏸️  Push cancelado. Puedes hacerlo manualmente con: git push" -ForegroundColor Yellow
    }
}
else {
    Write-Host ""
    Write-Host "❌ Operación cancelada" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Limpiar workflows antiguos: .\scripts\cleanup-old-workflows.ps1" -ForegroundColor White
Write-Host "  2. Habilitar push de tags: .\scripts\enable-git-push-in-jenkins.ps1" -ForegroundColor White
Write-Host "  3. Configurar credenciales en Jenkins" -ForegroundColor White
Write-Host "  4. Probar con un release" -ForegroundColor White
