Write-Host "Revirtiendo comandos bat a sh para Jenkins en Linux..." -ForegroundColor Cyan

$services = "user-service","product-service","order-service","payment-service","favourite-service","shipping-service"
$updated = 0

foreach ($svc in $services) {
    $file = "$svc/Jenkinsfile"
    if (Test-Path $file) {
        Write-Host "Procesando $file..." -ForegroundColor Yellow
        $text = Get-Content $file -Raw
        if ($text -match 'bat """') {
            $text = $text -replace 'bat """', 'sh """'
            $text = $text -replace '@echo off', '# Script de deployment'
            $text = $text -replace 'echo ', 'echo '
            $text = $text -replace 'REM ', '# '
            $text = $text -replace '%K8S_NAMESPACE%', '${K8S_NAMESPACE}'
            $text = $text -replace '%SERVICE_NAME%', '${SERVICE_NAME}'
            $text = $text -replace '%IMAGE_NAME%', '${IMAGE_NAME}'
            $text = $text -replace '%BUILD_TAG%', '${BUILD_TAG}'
            $text = $text -replace '%SERVICE_PORT%', '${SERVICE_PORT}'
            $text = $text -replace '\^', ''
            Set-Content $file $text -NoNewline
            Write-Host "Revertido OK" -ForegroundColor Green
            $updated++
        }
    }
}

Write-Host "Total revertidos: $updated archivos" -ForegroundColor Cyan
Write-Host "Jenkins en Docker usa Linux, por lo que necesita comandos sh" -ForegroundColor Yellow
