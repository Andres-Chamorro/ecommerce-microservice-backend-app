# Script para actualizar todos los Jenkinsfiles con docker save/load

$services = @(
    "user-service",
    "product-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Actualizando Jenkinsfiles con docker save/load..." -ForegroundColor Cyan

foreach ($service in $services) {
    Write-Host "`nActualizando $service..." -ForegroundColor Yellow
    
    # Leer el Jenkinsfile.dev de order-service como template (ya está correcto)
    $templateContent = Get-Content "order-service/Jenkinsfile.dev" -Raw -Encoding UTF8
    
    # Extraer el bloque de Build Docker Image
    $buildStagePattern = '(?s)stage\(''Build Docker Image''\).*?sh """.*?"""'
    if ($templateContent -match $buildStagePattern) {
        $buildStageBlock = $matches[0]
        
        # Reemplazar el nombre del servicio en el bloque
        $serviceBuildBlock = $buildStageBlock -replace 'order-service', $service
        
        # Leer el Jenkinsfile.dev del servicio actual
        $jenkinsfileDev = "$service/Jenkinsfile.dev"
        if (Test-Path $jenkinsfileDev) {
            $content = Get-Content $jenkinsfileDev -Raw -Encoding UTF8
            
            # Reemplazar el stage completo
            $content = $content -replace $buildStagePattern, $serviceBuildBlock
            
            # Guardar
            $content | Out-File -FilePath $jenkinsfileDev -Encoding UTF8 -NoNewline
            Write-Host "  Jenkinsfile.dev actualizado!" -ForegroundColor Green
        }
    }
}

Write-Host "`nCopiando Jenkinsfile.dev a Jenkinsfile..." -ForegroundColor Cyan
foreach ($service in $services + @("order-service")) {
    Copy-Item -Path "$service/Jenkinsfile.dev" -Destination "$service/Jenkinsfile" -Force
    Write-Host "  $service/Jenkinsfile actualizado!" -ForegroundColor Green
}

Write-Host "`nActualizacion completada!" -ForegroundColor Green
