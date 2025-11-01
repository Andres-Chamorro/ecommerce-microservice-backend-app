# Script para cargar imágenes de Docker en Minikube rápidamente
param(
    [Parameter(Mandatory=$true)]
    [string]$ImageName
)

Write-Host "Cargando imagen $ImageName en Minikube..." -ForegroundColor Cyan

# Usar minikube image load (mucho más rápido que docker save/load)
minikube image load $ImageName

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Imagen $ImageName cargada exitosamente en Minikube" -ForegroundColor Green
} else {
    Write-Host "✗ Error al cargar imagen $ImageName" -ForegroundColor Red
    exit 1
}
