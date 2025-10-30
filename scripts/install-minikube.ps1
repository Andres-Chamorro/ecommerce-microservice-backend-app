# Script para instalar Minikube en Windows

Write-Host "Instalando Minikube en Windows..." -ForegroundColor Cyan
Write-Host ""

# Verificar si Minikube ya esta instalado
$minikubeInstalled = Get-Command minikube -ErrorAction SilentlyContinue

if ($minikubeInstalled) {
    Write-Host "Minikube ya esta instalado" -ForegroundColor Green
    minikube version
    Write-Host ""
    Write-Host "Quieres reinstalar? (S/N)" -ForegroundColor Yellow
    $reinstall = Read-Host
    if ($reinstall -ne "S" -and $reinstall -ne "s") {
        Write-Host "Saltando instalacion..." -ForegroundColor Yellow
        exit 0
    }
}

# Crear directorio para Minikube
Write-Host "1. Creando directorio C:\minikube..." -ForegroundColor Green
New-Item -Path 'C:\' -Name 'minikube' -ItemType Directory -Force | Out-Null

# Descargar Minikube
Write-Host "2. Descargando Minikube..." -ForegroundColor Green
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -OutFile 'C:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
$ProgressPreference = 'Continue'

# Agregar al PATH
Write-Host "3. Agregando Minikube al PATH..." -ForegroundColor Green
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube') {
    [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
    Write-Host "   PATH actualizado. Necesitas reiniciar PowerShell" -ForegroundColor Yellow
}

# Actualizar PATH en la sesion actual
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verificar instalacion
Write-Host ""
Write-Host "4. Verificando instalacion..." -ForegroundColor Green
& C:\minikube\minikube.exe version

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Minikube instalado exitosamente" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Reinicia PowerShell" -ForegroundColor White
Write-Host "  2. Ejecuta: minikube start --driver=docker" -ForegroundColor White
Write-Host "  3. Verifica: kubectl get nodes" -ForegroundColor White
Write-Host ""
