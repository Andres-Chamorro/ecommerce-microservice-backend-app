# Script para arreglar el stage de Build Docker Image en todos los servicios

$services = @(
    @{name='user-service'; port='8700'},
    @{name='shipping-service'; port='8600'},
    @{name='product-service'; port='8300'},
    @{name='payment-service'; port='8400'},
    @{name='order-service'; port='8300'},
    @{name='favourite-service'; port='8200'}
)

foreach ($svc in $services) {
    $service = $svc.name
    $file = "$service/Jenkinsfile"
    
    Write-Host "Procesando $file..." -ForegroundColor Cyan
    
    $content = Get-Content $file -Raw
    
    # Crear el nuevo bloque de build
    $newBuildBlock = @"
                    sh """
                        # Copiar contexto de build a minikube
                        docker cp $service minikube:/tmp/build-context/
                        
                        # Construir directamente en minikube (SIN transferencia de imagen)
                        docker exec minikube docker build -t \${IMAGE_NAME}:dev-\${BUILD_TAG} /tmp/build-context
                        docker exec minikube docker tag \${IMAGE_NAME}:dev-\${BUILD_TAG} \${IMAGE_NAME}:dev-latest
                        
                        # Limpiar
                        docker exec minikube rm -rf /tmp/build-context
                        
                        echo "✓ Imagen construida directamente en Minikube: \${IMAGE_NAME}:dev-\${BUILD_TAG}"
                    """
"@
    
    # Buscar el bloque sh """ que contiene docker build
    if ($content -match '(?s)(stage\(''Build Docker Image''\).*?sh """).*?(""")') {
        # Extraer todo entre sh """ y el cierre """
        $pattern = '(?s)(sh """\s*#[^\n]*\n.*?)(docker save.*?\n\s*)(echo "Imagen construida.*?""")'
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $newBuildBlock
            
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText("$PWD\$file", $content, $utf8NoBom)
            
            Write-Host "✓ Actualizado $file" -ForegroundColor Green
        } else {
            Write-Host "⚠ No se encontró el patrón en $file" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✓ Proceso completado!" -ForegroundColor Green
Write-Host "Las imágenes ahora se construyen directamente en minikube (mucho más rápido)" -ForegroundColor Cyan
