Write-Host "Actualizando deployment para usar pipe directo..." -ForegroundColor Cyan

$services = @(
    @{name="user-service"; port="8300"},
    @{name="order-service"; port="8100"},
    @{name="product-service"; port="8200"},
    @{name="payment-service"; port="8400"},
    @{name="shipping-service"; port="8500"},
    @{name="favourite-service"; port="8600"}
)

foreach ($service in $services) {
    $serviceName = $service.name
    $servicePort = $service.port
    $jenkinsfile = "$serviceName/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar el bloque de creacion de deployment
        $oldBlock = @"
                        # Crear archivo de deployment temporal
                        cat > /tmp/deployment-\`${SERVICE_NAME}.yaml <<'EOFYAML'
"@

        $newBlock = @"
                        # Aplicar deployment directamente con pipe
                        cat <<'EOFYAML' | docker exec -i minikube /var/lib/minikube/binaries/v1.34.0/kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f -
"@

        $content = $content -replace [regex]::Escape($oldBlock), $newBlock
        
        # Remover las lineas de docker cp y limpieza
        $content = $content -replace '\s+# Copiar archivo a Minikube y aplicar[\s\S]*?# Limpiar archivos temporales[\s\S]*?docker exec minikube rm -f /tmp/deployment-\$\{SERVICE_NAME\}\.yaml\s+', "`n                        "
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nTodos los Jenkinsfiles actualizados con pipe directo para deployment" -ForegroundColor Green
