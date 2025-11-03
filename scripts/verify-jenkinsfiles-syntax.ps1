# Script para verificar sintaxis de todos los Jenkinsfiles

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

$jenkinsfiles = @(
    "Jenkinsfile",
    "Jenkinsfile.dev",
    "Jenkinsfile.staging",
    "Jenkinsfile.master"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFICACION DE SINTAXIS DE JENKINSFILES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalFiles = 0
$checkedFiles = 0
$errorFiles = 0
$warningFiles = 0

# Patrones problemáticos conocidos
$problematicPatterns = @(
    @{
        Pattern = '\$\{SERVICE_NAME#\*-\}'
        Description = "Sintaxis bash incompatible: \${SERVICE_NAME#*-}"
        Severity = "ERROR"
    },
    @{
        Pattern = '\$\{[^}]*#[^}]*\}'
        Description = "Sintaxis bash de manipulacion de strings"
        Severity = "WARNING"
    },
    @{
        Pattern = '\$\{SERVICE_PORT\}'
        Description = "Variable SERVICE_PORT sin escapar"
        Severity = "WARNING"
    }
)

foreach ($service in $services) {
    Write-Host "Verificando $service..." -ForegroundColor Yellow
    
    foreach ($jenkinsfile in $jenkinsfiles) {
        $filePath = "$service/$jenkinsfile"
        $totalFiles++
        
        if (Test-Path $filePath) {
            $checkedFiles++
            $content = Get-Content $filePath -Raw
            $hasErrors = $false
            $hasWarnings = $false
            
            # Verificar cada patrón problemático
            foreach ($pattern in $problematicPatterns) {
                if ($content -match $pattern.Pattern) {
                    $matches = [regex]::Matches($content, $pattern.Pattern)
                    
                    if ($pattern.Severity -eq "ERROR") {
                        Write-Host "   [ERROR] $filePath" -ForegroundColor Red
                        Write-Host "      $($pattern.Description)" -ForegroundColor Red
                        Write-Host "      Encontradas $($matches.Count) ocurrencias" -ForegroundColor Red
                        $hasErrors = $true
                    }
                    else {
                        Write-Host "   [WARNING] $filePath" -ForegroundColor Yellow
                        Write-Host "      $($pattern.Description)" -ForegroundColor Yellow
                        Write-Host "      Encontradas $($matches.Count) ocurrencias" -ForegroundColor Yellow
                        $hasWarnings = $true
                    }
                }
            }
            
            if ($hasErrors) {
                $errorFiles++
            }
            elseif ($hasWarnings) {
                $warningFiles++
            }
            else {
                Write-Host "   [OK] $filePath" -ForegroundColor Green
            }
        }
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE VERIFICACION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total de archivos esperados: $totalFiles" -ForegroundColor White
Write-Host "Archivos verificados: $checkedFiles" -ForegroundColor White
Write-Host "Archivos con ERRORES: $errorFiles" -ForegroundColor $(if ($errorFiles -gt 0) { "Red" } else { "Green" })
Write-Host "Archivos con WARNINGS: $warningFiles" -ForegroundColor $(if ($warningFiles -gt 0) { "Yellow" } else { "Green" })
Write-Host "Archivos OK: $($checkedFiles - $errorFiles - $warningFiles)" -ForegroundColor Green
Write-Host ""

if ($errorFiles -eq 0 -and $warningFiles -eq 0) {
    Write-Host "TODOS LOS JENKINSFILES ESTAN CORRECTOS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verificaciones realizadas:" -ForegroundColor Cyan
    Write-Host "   Sintaxis bash incompatible con Groovy" -ForegroundColor White
    Write-Host "   Manipulacion de strings problematica" -ForegroundColor White
    Write-Host "   Variables sin escapar correctamente" -ForegroundColor White
    Write-Host ""
    Write-Host "Estado: LISTO PARA JENKINS" -ForegroundColor Green
    exit 0
}
elseif ($errorFiles -eq 0) {
    Write-Host "Verificacion completada con WARNINGS" -ForegroundColor Yellow
    Write-Host "Los warnings no bloquean la ejecucion pero deben revisarse" -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "ERRORES ENCONTRADOS - REQUIERE CORRECCION" -ForegroundColor Red
    Write-Host "Los archivos con errores no funcionaran en Jenkins" -ForegroundColor Red
    exit 1
}
