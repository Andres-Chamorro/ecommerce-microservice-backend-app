# Script para corregir el patrón E2E en los Jenkinsfiles de staging
# Cambia de 'cd tests/e2e' a usar dir() y simplifica Maven

$services = @("product-service", "order-service", "payment-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📝 Procesando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw -Encoding UTF8
        
        # Buscar el bloque que contiene "cd tests/e2e" y reemplazarlo
        $oldPattern = @'
                        # Ejecutar pruebas E2E si existen
                        if \[ -d tests/e2e \]; then
                            echo "??Ejecutando pruebas E2E..."
                            cd tests/e2e
                            JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
                            PATH=\$JAVA_HOME/bin:\$PATH
                            /usr/bin/mvn test -Dtest=\*E2ETest -Dservice\.url=http://\$SERVICE_URL:\$\{SERVICE_PORT\} -Dservice\.name=\$\{SERVICE_NAME\} \|\| echo "Algunas pruebas E2E fallaron"
                        else
                            echo "No hay pruebas E2E configuradas"
                        fi
'@

        $newPattern = @'
                        # Guardar variables para usar fuera del script
                        echo "$SERVICE_URL" > /tmp/service_url.txt
                        echo "$PORT_FORWARD_PID" > /tmp/port_forward_pid.txt
                    '''
                    
                    // Ejecutar pruebas E2E usando dir() para mantener el contexto
                    if (fileExists('tests/e2e/pom.xml')) {
                        dir('tests/e2e') {
                            sh '''
                                SERVICE_URL=$(cat /tmp/service_url.txt)
                                echo "Ejecutando pruebas E2E contra: http://$SERVICE_URL:${SERVICE_PORT}"
                                mvn test -Dtest=*E2ETest -Dservice.url=http://$SERVICE_URL:${SERVICE_PORT} -Dservice.name=${SERVICE_NAME} || echo "Algunas pruebas E2E fallaron"
                            '''
                        }
                    } else {
                        echo "No hay pruebas E2E configuradas"
                    }
                    
                    // Limpiar port-forward si se usó
                    sh '''
                        if [ -f /tmp/port_forward_pid.txt ]; then
                            PORT_FORWARD_PID=$(cat /tmp/port_forward_pid.txt)
                            if [ -n "$PORT_FORWARD_PID" ] && [ "$PORT_FORWARD_PID" != "" ]; then
                                kill $PORT_FORWARD_PID 2>/dev/null || true
                            fi
                        fi
                        rm -f /tmp/service_url.txt /tmp/port_forward_pid.txt
'@

        if ($content -match [regex]::Escape($oldPattern)) {
            $content = $content -replace [regex]::Escape($oldPattern), $newPattern
            Set-Content -Path $jenkinsfile -Value $content -NoNewline -Encoding UTF8
            Write-Host "  ✅ $jenkinsfile actualizado correctamente" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Patrón no encontrado en $jenkinsfile - buscando alternativa..." -ForegroundColor Yellow
            
            # Intentar con un patrón más simple
            if ($content -match 'cd tests/e2e') {
                Write-Host "  ℹ️ Encontrado 'cd tests/e2e', aplicando reemplazo manual..." -ForegroundColor Cyan
                
                # Reemplazar el bloque completo desde "# Ejecutar pruebas E2E" hasta el fi
                $content = $content -replace '(?s)(# Ejecutar pruebas E2E si existen.*?)(# Limpiar port-forward)', @"
# Guardar variables para usar fuera del script
                        echo "`$SERVICE_URL" > /tmp/service_url.txt
                        echo "`$PORT_FORWARD_PID" > /tmp/port_forward_pid.txt
                    '''
                    
                    // Ejecutar pruebas E2E usando dir() para mantener el contexto
                    if (fileExists('tests/e2e/pom.xml')) {
                        dir('tests/e2e') {
                            sh '''
                                SERVICE_URL=`$(cat /tmp/service_url.txt)
                                echo "Ejecutando pruebas E2E contra: http://`$SERVICE_URL:`${SERVICE_PORT}"
                                mvn test -Dtest=*E2ETest -Dservice.url=http://`$SERVICE_URL:`${SERVICE_PORT} -Dservice.name=`${SERVICE_NAME} || echo "Algunas pruebas E2E fallaron"
                            '''
                        }
                    } else {
                        echo "No hay pruebas E2E configuradas"
                    }
                    
                    // `$2
"@
                
                Set-Content -Path $jenkinsfile -Value $content -NoNewline -Encoding UTF8
                Write-Host "  ✅ $jenkinsfile actualizado con patrón alternativo" -ForegroundColor Green
            } else {
                Write-Host "  ❌ No se pudo encontrar el patrón en $jenkinsfile" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  ⚠️ Archivo no encontrado: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Proceso completado" -ForegroundColor Green
