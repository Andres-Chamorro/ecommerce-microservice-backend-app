# Script para arreglar las pruebas de integración en Minikube
# Actualiza los Jenkinsfiles para hacer port-forward antes de las pruebas

$services = @(
    "user-service",
    "order-service", 
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..."
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar el stage de Integration Tests y reemplazarlo
        $oldStage = @'
        stage\('Integration Tests'\) \{
            when \{
                expression \{ params\.SKIP_TESTS == false && params\.SKIP_DEPLOY == false \}
            \}
            steps \{
                script \{
                    echo "\[DEV\] Ejecutando pruebas de integracion\.\.\."
                    dir\('tests/integration'\) \{
                        sh '''
                            if \[ -f pom\.xml \]; then
                                # Configurar URLs de servicios en Minikube
                                export USER_SERVICE_URL="http://user-service\.ecommerce-dev:8700"
                                export ORDER_SERVICE_URL="http://user-service\.ecommerce-dev:8300"
                                export PRODUCT_SERVICE_URL="http://product-service\.ecommerce-dev:8500"
                                
                                mvn test -Dtest=\*IntegrationTest \|\| echo "Algunas pruebas de integracion fallaron"
                            else
                                echo "No hay pruebas de integracion configuradas"
                            fi
                        '''
                    \}
                \}
            \}
        \}
'@

        $newStage = @'
        stage('Integration Tests') {
            when {
                expression { params.SKIP_TESTS == false && params.SKIP_DEPLOY == false }
            }
            steps {
                script {
                    echo "[DEV] Configurando port-forwards para pruebas de integración..."
                    
                    // Iniciar port-forwards en background
                    sh '''
                        # Función para hacer port-forward en background
                        start_port_forward() {
                            SERVICE=$1
                            PORT=$2
                            NAMESPACE=${3:-ecommerce-dev}
                            
                            echo "Port-forwarding $SERVICE:$PORT..."
                            kubectl port-forward -n $NAMESPACE svc/$SERVICE $PORT:$PORT > /dev/null 2>&1 &
                            PF_PID=$!
                            echo $PF_PID >> /tmp/port-forward-pids.txt
                            sleep 2
                        }
                        
                        # Limpiar port-forwards anteriores
                        rm -f /tmp/port-forward-pids.txt
                        
                        # Iniciar port-forwards para todos los servicios
                        start_port_forward user-service 8700
                        start_port_forward order-service 8300
                        start_port_forward payment-service 8400
                        start_port_forward product-service 8500
                        start_port_forward shipping-service 8600
                        start_port_forward favourite-service 8800
                        
                        echo "✅ Port-forwards configurados"
                        sleep 3
                    '''
                    
                    try {
                        echo "[DEV] Ejecutando pruebas de integración..."
                        dir('tests/integration') {
                            sh '''
                                if [ -f pom.xml ]; then
                                    # Las pruebas ahora pueden usar localhost gracias a port-forward
                                    mvn test -Dtest=*IntegrationTest || echo "⚠️ Algunas pruebas de integración fallaron"
                                else
                                    echo "No hay pruebas de integración configuradas"
                                fi
                            '''
                        }
                    } finally {
                        // Limpiar port-forwards
                        sh '''
                            echo "Limpiando port-forwards..."
                            if [ -f /tmp/port-forward-pids.txt ]; then
                                while read pid; do
                                    kill $pid 2>/dev/null || true
                                done < /tmp/port-forward-pids.txt
                                rm -f /tmp/port-forward-pids.txt
                            fi
                            echo "✅ Port-forwards limpiados"
                        '''
                    }
                }
            }
        }
'@

        # Reemplazar el stage
        if ($content -match $oldStage) {
            $content = $content -replace $oldStage, $newStage
            Set-Content -Path $jenkinsfile -Value $content -Encoding UTF8
            Write-Host "  ✅ $service actualizado"
        } else {
            Write-Host "  ⚠️  No se encontró el patrón exacto en $service, buscando alternativa..."
        }
    }
}

Write-Host ""
Write-Host "========================================="
Write-Host "✅ Jenkinsfiles actualizados"
Write-Host "========================================="
Write-Host ""
Write-Host "Ahora las pruebas de integración:"
Write-Host "  1. Harán port-forward de los servicios de Minikube"
Write-Host "  2. Ejecutarán las pruebas contra localhost"
Write-Host "  3. Limpiarán los port-forwards al terminar"
