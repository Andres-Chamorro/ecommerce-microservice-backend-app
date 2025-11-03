# Script para corregir todos los Jenkinsfiles de staging

$services = @(
    "user-service",
    "product-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Corrigiendo $jenkinsfile..."
        
        $content = Get-Content $jenkinsfile -Raw
        
        # 1. Cambiar JAVA_HOME
        $content = $content -replace "JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'", "JAVA_HOME = '/opt/java/openjdk'"
        
        # 2. Agregar CLOUDSDK_PYTHON después de USE_GKE_GCLOUD_AUTH_PLUGIN
        $content = $content -replace "(USE_GKE_GCLOUD_AUTH_PLUGIN = 'True')", "`$1`n        CLOUDSDK_PYTHON = '/usr/bin/python3'"
        
        # 3. Eliminar todas las líneas ". /root/google-cloud-sdk/path.bash.inc"
        $content = $content -replace "\s+\. /root/google-cloud-sdk/path\.bash\.inc\r?\n", ""
        
        # Guardar cambios
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "✅ $jenkinsfile corregido"
    }
}

Write-Host "`n✅ Todos los Jenkinsfiles han sido corregidos"
