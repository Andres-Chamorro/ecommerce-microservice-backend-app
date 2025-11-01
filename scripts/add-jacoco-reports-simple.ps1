Write-Host "Agregando stage de JaCoCo a Jenkinsfiles..." -ForegroundColor Cyan

$services = @("user-service", "order-service", "product-service", "payment-service", "shipping-service", "favourite-service")

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar el stage Integration Tests y agregar el stage de JaCoCo antes del post section
        $jacocoStage = @"
        
        stage('Code Coverage Report') {
            when {
                expression { params.SKIP_TESTS == false }
            }
            steps {
                script {
                    echo "[DEV] Generando reporte de cobertura de codigo..."
                    dir('$service') {
                        sh 'mvn jacoco:report || echo "WARNING: No se pudo generar reporte JaCoCo"'
                    }
                }
            }
            post {
                always {
                    jacoco(
                        execPattern: '$service/target/jacoco.exec',
                        classPattern: '$service/target/classes',
                        sourcePattern: '$service/src/main/java',
                        exclusionPattern: '**/*Test*.class'
                    )
                }
            }
        }
"@

        # Agregar el stage antes del cierre de stages
        $content = $content -replace '(\s+)\}\s+post \{', "$jacocoStage`n`$1}`n`n    post {"
        
        $content | Set-Content $jenkinsfile -NoNewline
        
        Write-Host "OK $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host "`nStage de JaCoCo agregado a todos los Jenkinsfiles" -ForegroundColor Green
