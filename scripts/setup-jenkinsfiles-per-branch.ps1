# Script para configurar Jenkinsfiles en cada rama
# Copia Jenkinsfile.dev -> Jenkinsfile en rama dev
# Copia Jenkinsfile.staging -> Jenkinsfile en rama staging
# Copia Jenkinsfile.master -> Jenkinsfile en rama master

Write-Host "Configurando Jenkinsfiles por rama..." -ForegroundColor Cyan
Write-Host ""

$services = @(
    'user-service',
    'product-service',
    'order-service',
    'payment-service',
    'favourite-service',
    'shipping-service'
)

# Guardar rama actual
$currentBranch = git branch --show-current
Write-Host "Rama actual: $currentBranch" -ForegroundColor Yellow
Write-Host ""

# Verificar que no hay cambios sin commitear
$status = git status --porcelain
if ($status) {
    Write-Host "ERROR: Tienes cambios sin commitear" -ForegroundColor Red
    Write-Host "Por favor, haz commit o stash de tus cambios primero" -ForegroundColor Yellow
    exit 1
}

# Procesar cada rama
$branches = @(
    @{name='dev'; file='Jenkinsfile.dev'},
    @{name='staging'; file='Jenkinsfile.staging'},
    @{name='master'; file='Jenkinsfile.master'}
)

foreach ($branch in $branches) {
    $branchName = $branch.name
    $sourceFile = $branch.file
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Procesando rama: $branchName" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Cambiar a la rama
    Write-Host "Cambiando a rama $branchName..." -ForegroundColor Yellow
    git checkout $branchName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo cambiar a rama $branchName" -ForegroundColor Red
        continue
    }
    
    # Copiar Jenkinsfiles para cada servicio
    foreach ($service in $services) {
        $source = "$service/$sourceFile"
        $dest = "$service/Jenkinsfile"
        
        if (Test-Path $source) {
            Copy-Item $source $dest -Force
            Write-Host "  OK $service/$sourceFile -> $service/Jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "  ERROR $source no existe" -ForegroundColor Red
        }
    }
    
    # Hacer commit
    git add .
    $commitMsg = "chore: configurar Jenkinsfiles para rama $branchName"
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Commit realizado: $commitMsg" -ForegroundColor Green
    } else {
        Write-Host "No hay cambios para commitear en $branchName" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Volver a la rama original
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Volviendo a rama original: $currentBranch" -ForegroundColor Green
git checkout $currentBranch

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Resumen:" -ForegroundColor Yellow
Write-Host "  - Rama dev: usa Jenkinsfile (copiado de Jenkinsfile.dev)" -ForegroundColor White
Write-Host "  - Rama staging: usa Jenkinsfile (copiado de Jenkinsfile.staging)" -ForegroundColor White
Write-Host "  - Rama master: usa Jenkinsfile (copiado de Jenkinsfile.master)" -ForegroundColor White
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Push de las 3 ramas: git push origin dev staging master" -ForegroundColor White
Write-Host "  2. Jenkins detectara automaticamente los cambios" -ForegroundColor White
Write-Host "  3. Cada rama usara su Jenkinsfile correspondiente" -ForegroundColor White
Write-Host ""
