# Script para hacer las pruebas de integración más inteligentes
# Verifica que los servicios estén desplegados antes de ejecutar las pruebas

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando Integration Tests stage en $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar el stage de Integration Tests
        if ($content -match "stage\('Integration Tests'\)") {
            # Reemplazar el contenido del stage
            $oldStage = @'
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

            $newStage = @'
        stage('Integration Tests') {
            when {
                expression { params.SKIP_TESTS == false && params.SKIP_DEPLOY == false }
            }
            steps {
                script {
                    echo "[DEV] Verificando servicios desplegados para pruebas de integración..."
                    
                    // Verificar que todos los servicios estén desplegados
                    def servicesReady = sh(
                        script: '''
                            REQUIRED_SERVICES="user-service order-service payment-service product-service shipping-service favourite-service"
                            MISSING_SERVICES=""
                            
                            for svc in $REQUIRED_SERVICES; do
                                if ! docker exec minikube /var/lib/minikube/binaries/v1.34.0/kubectl --kubeconfig=/etc/kubernetes/admin.conf get svc -n ecommerce-dev $svc > /dev/null 2>&1; then
                                    MISSING_SERVICES="$MISSING_SERVICES $svc"
                                fi
                            done
                            
                            if [ -n "$MISSING_SERVICES" ]; then
                                echo "MISSING:$MISSING_SERVICES"
                                exit 1
                            else
                                echo "ALL_READY"
                                exit 0
                            fi
                        ''',
                        returnStatus: true
                    )
                    
                    if (servicesReady != 0) {
                        echo "⚠️ ADVERTENCIA: No todos los servicios están desplegados"
                        echo "Las pruebas de integración requieren que TODOS los servicios estén corriendo"
                        echo "Ejecuta los pipelines de todos los servicios primero:"
                        echo "  - user-service-pipeline"
                        echo "  - product-service-pipeline"
                        echo "  - order-service-pipeline"
                        echo "  - payment-service-pipeline"
                        echo "  - favourite-service-pipeline"
                        echo "  - shipping-service-pipeline"
                        echo ""
                        echo "Saltando pruebas de integración..."
                        return
                    }
                    
                    echo "[DEV] ✅ Todos los servicios están desplegados"
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

            $content = $content -replace [regex]::Escape($oldStage), $newStage
            
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "  ✓ Stage actualizado con verificación de servicios" -ForegroundColor Green
        } else {
            Write-Host "  - No tiene stage de Integration Tests" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✓ Actualización completada" -ForegroundColor Green
Write-Host "`nAhora los pipelines verificarán que todos los servicios estén desplegados" -ForegroundColor Cyan
Write-Host "antes de ejecutar las pruebas de integración" -ForegroundColor Cyan
