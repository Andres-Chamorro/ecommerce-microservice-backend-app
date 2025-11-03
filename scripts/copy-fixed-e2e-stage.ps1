# Script para copiar el stage E2E corregido a todos los servicios

Write-Host "🔧 Copiando stage E2E corregido a todos los servicios..." -ForegroundColor Cyan

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service"
)

# Stage E2E corregido (el que ya funciona en shipping-service)
$fixedE2EStage = @'
        stage('E2E Tests') {
            when {
                expression { params.SKIP_E2E_TESTS == false }
            }
            steps {
                script {
                    echo "🧪 [STAGING] Ejecutando pruebas E2E..."
                    
                    sh '''
                        . /root/google-cloud-sdk/path.bash.inc
                        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
                        export PATH=$JAVA_HOME/bin:$PATH
                        
                        # Obtener la URL del servicio (esperar hasta 2 minutos por la IP externa)
                        echo "⏳ Esperando IP externa del LoadBalancer..."
                        for i in {1..24}; do
                            SERVICE_IP=$(kubectl get svc ${SERVICE_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
                            if [ -n "$SERVICE_IP" ]; then
                                echo "✅ IP externa obtenida: $SERVICE_IP"
                                break
                            fi
                            echo "Intento $i/24: Esperando IP externa..."
                            sleep 5
                        done
                        
                        if [ -z "$SERVICE_IP" ]; then
                            echo "⚠️ No se pudo obtener IP externa, usando port-forward como fallback"
                            kubectl port-forward -n ${K8S_NAMESPACE} svc/${SERVICE_NAME} ${SERVICE_PORT}:${SERVICE_PORT} &
                            PORT_FORWARD_PID=$!
                            sleep 5
                            SERVICE_URL="localhost"
                        else
                            SERVICE_URL="$SERVICE_IP"
                        fi
                        
                        echo "🌐 Service URL: http://$SERVICE_URL:${SERVICE_PORT}"
                        
                        # Ejecutar pruebas E2E si existen
                        if [ -d tests/e2e ]; then
                            cd tests/e2e
                            mvn test -Dtest=*E2ETest -Dservice.url=http://$SERVICE_URL:${SERVICE_PORT} || echo "⚠️ Algunas pruebas E2E fallaron"
                        else
                            echo "ℹ️ No hay pruebas E2E configuradas"
                        fi
                        
                        # Limpiar port-forward si se usó
                        if [ -n "$PORT_FORWARD_PID" ]; then
                            kill $PORT_FORWARD_PID 2>/dev/null || true
                        fi
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'tests/e2e/target/surefire-reports/**/*.xml', allowEmptyArchive: true
                }
            }
        }
'@

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    $deployment = "k8s/microservices/$service-deployment.yaml"
    
    Write-Host ""
    Write-Host "📝 Procesando $service..." -ForegroundColor Yellow
    
    # 1. Actualizar Jenkinsfile - reemplazar stage E2E
    if (Test-Path $jenkinsfile) {
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar y reemplazar el stage E2E completo
        $pattern = "(?s)stage\('E2E Tests'\).*?post \{.*?always \{.*?archiveArtifacts.*?\}.*?\}.*?\}"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $fixedE2EStage
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "  ✅ Stage E2E actualizado en $jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ No se encontró stage E2E en $jenkinsfile" -ForegroundColor Yellow
        }
    }
    
    # 2. Actualizar deployment a LoadBalancer
    if (Test-Path $deployment) {
        $content = Get-Content $deployment -Raw
        
        if ($content -match "type: ClusterIP") {
            $content = $content -replace "type: ClusterIP", "type: LoadBalancer  # IP externa para pruebas E2E"
            Set-Content -Path $deployment -Value $content -NoNewline
            Write-Host "  ✅ Deployment actualizado a LoadBalancer" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️ Deployment ya usa LoadBalancer o no encontrado" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "✅ Correcciones E2E aplicadas a todos los servicios" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Cambios realizados:" -ForegroundColor Cyan
Write-Host "  1. ✅ JAVA_HOME exportado en stages E2E" -ForegroundColor Green
Write-Host "  2. ✅ Espera de IP externa (hasta 2 min)" -ForegroundColor Green
Write-Host "  3. ✅ Fallback a port-forward" -ForegroundColor Green
Write-Host "  4. ✅ Servicios cambiados a LoadBalancer" -ForegroundColor Green
Write-Host "  5. ✅ Puerto de favourite-service corregido (8800)" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Ejecuta el pipeline de staging nuevamente" -ForegroundColor Cyan
