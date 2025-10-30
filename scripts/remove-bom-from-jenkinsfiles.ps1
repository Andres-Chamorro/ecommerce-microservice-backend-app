# Script para eliminar BOM (Byte Order Mark) de los Jenkinsfiles

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

Write-Host "Eliminando BOM de Jenkinsfiles..." -ForegroundColor Cyan

foreach ($service in $services) {
    foreach ($file in @("Jenkinsfile", "Jenkinsfile.dev")) {
        $jenkinsfile = "$service/$file"
        
        if (Test-Path $jenkinsfile) {
            Write-Host "`nProcesando $jenkinsfile..." -ForegroundColor Yellow
            
            # Leer contenido como bytes
            $bytes = [System.IO.File]::ReadAllBytes($jenkinsfile)
            
            # Verificar si tiene BOM UTF-8 (EF BB BF)
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
                Write-Host "  BOM encontrado! Eliminando..." -ForegroundColor Red
                
                # Eliminar los primeros 3 bytes (BOM)
                $bytesWithoutBOM = $bytes[3..($bytes.Length-1)]
                
                # Guardar sin BOM
                [System.IO.File]::WriteAllBytes($jenkinsfile, $bytesWithoutBOM)
                
                Write-Host "  BOM eliminado!" -ForegroundColor Green
            } else {
                Write-Host "  Sin BOM - OK" -ForegroundColor Green
            }
        }
    }
}

Write-Host "`nLimpieza completada!" -ForegroundColor Green
