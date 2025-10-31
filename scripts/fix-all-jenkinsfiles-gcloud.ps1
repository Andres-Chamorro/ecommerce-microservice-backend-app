# Script para arreglar todos los Jenkinsfiles con la inicialización correcta de gcloud

Write-Host "🔧 Actualizando todos los Jenkinsfiles con inicialización de gcloud..." -ForegroundColor Cyan

$services = @(
    'user-service',
    'order-service',
    'payment-service',
    'shipping-service',
    'favourite-service'
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📝 Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        # Leer contenido
        $content = Get-Content $jenkinsfile -Raw
        
        # 1. Actualizar PATH para incluir gcloud
        $oldPath = 'PATH = "${JAVA_HOME}/bin:${env.PATH}"'
        $newPath = 'PATH = "/root/google-cloud-sdk/bin:${JAVA_HOME}/bin:${env.PATH}"'
        $content = $content.Replace($oldPath, $newPath)
        
        # 2. Agregar inicialización de gcloud antes de gcloud auth configure-docker
        $oldAuth = "                        # Autenticar con GCP usando gcloud`n                        gcloud auth configure-docker"
        $newAuth = "                        # Inicializar gcloud`n                        . /root/google-cloud-sdk/path.bash.inc || true`n                        `n                        # Autenticar con GCP usando gcloud`n                        gcloud auth configure-docker"
        $content = $content.Replace($oldAuth, $newAuth)
        
        # Guardar cambios
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "✅ $jenkinsfile actualizado" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  $jenkinsfile no encontrado" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Todos los Jenkinsfiles actualizados correctamente" -ForegroundColor Green
Write-Host ""
Write-Host "Los cambios aplicados:" -ForegroundColor Cyan
Write-Host "1. PATH ahora incluye /root/google-cloud-sdk/bin"
Write-Host "2. Se inicializa gcloud antes de usarlo con: . /root/google-cloud-sdk/path.bash.inc"
Write-Host ""
Write-Host "Ahora puedes ejecutar los pipelines sin el error 'gcloud: not found'" -ForegroundColor Green
