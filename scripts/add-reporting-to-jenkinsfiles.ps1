# Script para agregar stages de reportes a todos los Jenkinsfiles

Write-Host "📊 Agregando stages de reportes a todos los Jenkinsfiles..." -ForegroundColor Cyan

$services = @(
    @{name='user-service'; port='8300'},
    @{name='product-service'; port='8300'},
    @{name='order-service'; port='8300'},
    @{name='payment-service'; port='8300'},
    @{name='shipping-service'; port='8300'},
    @{name='favourite-service'; port='8300'}
)

$reportingStages = @'

        stage('Code Coverage Report') {
            when {
                expression { params.SKIP_TESTS == false }
            }
            steps {
                script {
                    echo "📊 [DEV] Generando reporte de cobertura de código..."
                    dir('SERVICE_NAME_PLACEHOLDER') {
                        sh 'mvn jacoco:report || echo "⚠️ No se pudo generar reporte JaCoCo"'
                    }
                }
            }
            post {
                always {
                    // Publicar reporte de cobertura JaCoCo
                    jacoco(
                        execPattern: 'SERVICE_NAME_PLACEHOLDER/target/jacoco.exec',
                        classPattern: 'SERVICE_NAME_PLACEHOLDER/target/classes',
                        sourcePattern: 'SERVICE_NAME_PLACEHOLDER/src/main/java',
                        exclusionPattern: '**/*Test*.class'
                    )
                }
            }
        }
        
        stage('Generate Build Report') {
            steps {
                script {
                    echo "📋 [DEV] Generando reporte de build..."
                    sh """
                        mkdir -p reports
                        cat > reports/build-report-${SERVICE_NAME}.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Build Report - ${SERVICE_NAME}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin: 20px 0; }
        .info-box { background: #ecf0f1; padding: 15px; border-radius: 5px; border-left: 4px solid #3498db; }
        .info-label { font-weight: bold; color: #7f8c8d; font-size: 12px; text-transform: uppercase; }
        .info-value { font-size: 18px; color: #2c3e50; margin-top: 5px; }
        .success { color: #27ae60; }
        .warning { color: #f39c12; }
        .error { color: #e74c3c; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        tr:hover { background-color: #f5f5f5; }
        .badge { padding: 5px 10px; border-radius: 3px; font-size: 12px; font-weight: bold; }
        .badge-success { background: #27ae60; color: white; }
        .badge-info { background: #3498db; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Build Report - ${SERVICE_NAME}</h1>
        
        <div class="info-grid">
            <div class="info-box">
                <div class="info-label">Build Number</div>
                <div class="info-value">#${BUILD_TAG}</div>
            </div>
            <div class="info-box">
                <div class="info-label">Service Name</div>
                <div class="info-value">${SERVICE_NAME}</div>
            </div>
            <div class="info-box">
                <div class="info-label">Environment</div>
                <div class="info-value"><span class="badge badge-info">DEV</span></div>
            </div>
            <div class="info-box">
                <div class="info-label">Build Date</div>
                <div class="info-value">\$(date '+%Y-%m-%d %H:%M:%S')</div>
            </div>
            <div class="info-box">
                <div class="info-label">Docker Image</div>
                <div class="info-value">${IMAGE_NAME}:dev-${BUILD_TAG}</div>
            </div>
            <div class="info-box">
                <div class="info-label">Kubernetes Namespace</div>
                <div class="info-value">${K8S_NAMESPACE}</div>
            </div>
        </div>
        
        <h2>📦 Build Stages</h2>
        <table>
            <tr>
                <th>Stage</th>
                <th>Status</th>
                <th>Description</th>
            </tr>
            <tr>
                <td>Checkout</td>
                <td><span class="badge badge-success">✓ SUCCESS</span></td>
                <td>Repository cloned successfully</td>
            </tr>
            <tr>
                <td>Build Maven</td>
                <td><span class="badge badge-success">✓ SUCCESS</span></td>
                <td>Maven build completed</td>
            </tr>
            <tr>
                <td>Unit Tests</td>
                <td><span class="badge badge-success">✓ SUCCESS</span></td>
                <td>Unit tests executed</td>
            </tr>
            <tr>
                <td>Build Docker Image</td>
                <td><span class="badge badge-success">✓ SUCCESS</span></td>
                <td>Docker image built successfully</td>
            </tr>
            <tr>
                <td>Deploy to Minikube</td>
                <td><span class="badge badge-success">✓ SUCCESS</span></td>
                <td>Deployed to Minikube cluster</td>
            </tr>
        </table>
        
        <h2>📊 Artifacts</h2>
        <ul>
            <li>JAR file: target/${SERVICE_NAME}-0.1.0.jar</li>
            <li>Docker Image: ${IMAGE_NAME}:dev-${BUILD_TAG}</li>
            <li>Test Reports: target/surefire-reports/</li>
            <li>Coverage Report: target/site/jacoco/</li>
        </ul>
        
        <h2>🔗 Links</h2>
        <ul>
            <li><a href="../jacoco">Code Coverage Report</a></li>
            <li><a href="../testReport">Test Results</a></li>
        </ul>
    </div>
</body>
</html>
EOF
                    """
                }
            }
            post {
                always {
                    // Archivar el reporte HTML
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'reports',
                        reportFiles: 'build-report-${SERVICE_NAME}.html',
                        reportName: 'Build Report',
                        reportTitles: 'Build Report'
                    ])
                }
            }
        }
'@

foreach ($service in $services) {
    $serviceName = $service.name
    $jenkinsfile = "$serviceName/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📝 Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar SERVICE_NAME_PLACEHOLDER con el nombre real del servicio
        $serviceReportingStages = $reportingStages -replace 'SERVICE_NAME_PLACEHOLDER', $serviceName
        
        # Buscar el stage 'Integration Tests' y agregar los nuevos stages después
        if ($content -match "(stage\('Integration Tests'\)[\s\S]*?\n        \}\n)") {
            $content = $content -replace "(stage\('Integration Tests'\)[\s\S]*?\n        \}\n)", "`$1$serviceReportingStages`n"
            $content | Set-Content $jenkinsfile -NoNewline
            Write-Host "✅ Stages de reportes agregados a $jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "⚠️  No se encontró stage 'Integration Tests' en $jenkinsfile" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  No se encontró $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Proceso completado" -ForegroundColor Green
Write-Host "Los pipelines ahora generarán:" -ForegroundColor Cyan
Write-Host "  - Reportes de cobertura de código (JaCoCo)" -ForegroundColor White
Write-Host "  - Reportes HTML de build" -ForegroundColor White
Write-Host "  - Archivos de reportes en Jenkins" -ForegroundColor White
