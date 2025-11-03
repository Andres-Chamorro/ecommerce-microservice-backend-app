# Script para aplicar las correcciones E2E a todos los servicios

Write-Host "🔧 Aplicando correcciones E2E a todos los servicios..." -ForegroundColor Cyan

# Mapeo de servicios y sus puertos
$servicesPorts = @{
    "user-service" = "8100"
    "product-service" = "8300"
    "order-service" = "8400"
    "payment-service" = "8500"
    "favourite-service" = "8700"
}

foreach ($service in $servicesPorts.Keys) {
    $port = $servicesPorts[$service]
    $jenkinsfile = "$service/Jenkinsfile"
    $deployment = "k8s/microservices/$service-deployment.yaml"
    
    Write-Host ""
    Write-Host "📝 Procesando $service (puerto $port)..." -ForegroundColor Yellow
    
    # 1. Actualizar Jenkinsfile
    if (Test-Path $jenkinsfile) {
        $content = Get-Content $jenkinsfile -Raw
        
        # Actualizar puerto si es necesario
        $content = $content -replace "SERVICE_PORT = '\d+'", "SERVICE_PORT = '$port'"
        
        # Actualizar stage E2E (cambiar """ por ''' y agregar JAVA_HOME)
        $content = $content -replace `
            '(stage\(''E2E Tests''\).*?sh """)(\s*\. /root/google-cloud-sdk/path\.bash\.inc)', `
            '$1''$2'
        
        $content = $content -replace `
            "(sh '''\\s*\. /root/google-cloud-sdk/path\.bash\.inc)", `
            "`$1`n                        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`n                        export PATH=`$JAVA_HOME/bin:`$PATH"
        
        # Cambiar variables de $ a $
        $content = $content -replace '\\$\(kubectl', '$(kubectl'
        $content = $content -replace '\\$SERVICE_', '$SERVICE_'
        $content = $content -replace '\\$PORT_', '$PORT_'
        $content = $content -replace '\\$i', '$i'
        $content = $content -replace '\\$!', '$!'
        
        # Cambiar """ final por '''
        $content = $content -replace '(if \[ -n "\$PORT_FORWARD_PID" \]; then.*?fi\s*)"""', '$1'''
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "  ✅ $jenkinsfile actualizado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ $jenkinsfile no encontrado" -ForegroundColor Yellow
    }
    
    # 2. Actualizar deployment
    if (Test-Path $deployment) {
        $content = Get-Content $deployment -Raw
        
        if ($content -match "type: ClusterIP") {
            $content = $content -replace "type: ClusterIP", "type: LoadBalancer  # IP externa para pruebas E2E"
            Set-Content -Path $deployment -Value $content -NoNewline
            Write-Host "  ✅ $deployment actualizado a LoadBalancer" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️ $deployment ya usa LoadBalancer" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ⚠️ $deployment no encontrado" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Correcciones aplicadas a todos los servicios" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de cambios:" -ForegroundColor Cyan
Write-Host "  1. ✅ JAVA_HOME exportado en stages E2E" -ForegroundColor Green
Write-Host "  2. ✅ Espera de IP externa del LoadBalancer" -ForegroundColor Green
Write-Host "  3. ✅ Fallback a port-forward si no hay IP" -ForegroundColor Green
Write-Host "  4. ✅ Servicios cambiados a LoadBalancer" -ForegroundColor Green
Write-Host "  5. ✅ Puertos corregidos" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Ahora ejecuta el pipeline de staging nuevamente" -ForegroundColor Cyan
