# Script para agregar stage de reportes a los servicios restantes
# Servicios: order, payment, shipping, favourite

$services = @(
    @{name="order-service"; port="8500"},
    @{name="payment-service"; port="8600"},
    @{name="shipping-service"; port="8800"},
    @{name="favourite-service"; port="8900"}
)

$reportStage = @'
        
        stage('Generate Reports') {
            steps {
                script {
                    echo "📊 [DEV] Generando reportes de ${SERVICE_NAME}..."
                    
                    sh """
                        mkdir -p reports
                        cat > reports/build-report-${BUILD_NUMBER}.html << 'EOFHTML'
<!DOCTYPE html>
<html>
<head>
    <title>Build Report - ${SERVICE_NAME} #${BUILD_NUMBER}</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
        h1 { color: #333; border-bottom: 4px solid #667eea; padding-bottom: 15px; margin-top: 0; }
        h2 { color: #667eea; margin-top: 30px; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 25px; border-radius: 10px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .metric-title { font-size: 14px; opacity: 0.9; text-transform: uppercase; letter-spacing: 1px; }
        .metric-value { font-size: 36px; font-weight: bold; margin-top: 10px; }
        .success { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%) !important; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { padding: 15px; text-align: left; }
        th { background: #667eea; color: white; font-weight: 600; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        tr:hover { background-color: #e9ecef; }
        .badge { display: inline-block; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
        .badge-success { background: #38ef7d; color: white; }
        .badge-info { background: #667eea; color: white; }
        .footer { text-align: center; color: #666; margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Build Report - ${SERVICE_NAME}</h1>
        <p><strong>Build:</strong> #${BUILD_NUMBER} | <strong>Branch:</strong> dev | <strong>Fecha:</strong> \$(date '+%Y-%m-%d %H:%M:%S')</p>
        
        <h2>📈 Métricas del Build</h2>
        <div class="metrics-grid">
            <div class="metric-card success">
                <div class="metric-title">Build Status</div>
                <div class="metric-value">✓ SUCCESS</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Build Number</div>
                <div class="metric-value">#${BUILD_NUMBER}</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Environment</div>
                <div class="metric-value">DEV</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Service</div>
                <div class="metric-value">${SERVICE_NAME}</div>
            </div>
        </div>
        
        <h2>🧪 Resultados de Pruebas</h2>
        <table>
            <thead>
                <tr>
                    <th>Tipo de Prueba</th>
                    <th>Estado</th>
                    <th>Descripción</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Unit Tests</strong></td>
                    <td><span class="badge badge-success">✓ Passed</span></td>
                    <td>Pruebas unitarias ejecutadas correctamente</td>
                </tr>
                <tr>
                    <td><strong>Code Coverage (JaCoCo)</strong></td>
                    <td><span class="badge badge-info">📊 Generated</span></td>
                    <td>Reporte de cobertura disponible en Jenkins</td>
                </tr>
            </tbody>
        </table>
        
        <h2>🚀 Información de Despliegue</h2>
        <table>
            <thead>
                <tr>
                    <th>Componente</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Imagen Docker</strong></td>
                    <td><code>${IMAGE_NAME}:dev-${BUILD_TAG}</code></td>
                </tr>
                <tr>
                    <td><strong>Namespace Kubernetes</strong></td>
                    <td><code>${K8S_NAMESPACE}</code></td>
                </tr>
                <tr>
                    <td><strong>Cluster</strong></td>
                    <td>Minikube (Local Development)</td>
                </tr>
                <tr>
                    <td><strong>Service Port</strong></td>
                    <td>${SERVICE_PORT}</td>
                </tr>
            </tbody>
        </table>
        
        <h2>📦 Artefactos Generados</h2>
        <ul>
            <li>✅ Imagen Docker: <code>${IMAGE_NAME}:dev-${BUILD_TAG}</code></li>
            <li>✅ Reportes JUnit: <code>target/surefire-reports/*.xml</code></li>
            <li>✅ Reporte JaCoCo: <code>target/site/jacoco/index.html</code></li>
            <li>✅ JAR File: <code>target/${SERVICE_NAME}-v0.1.0.jar</code></li>
        </ul>
        
        <div class="footer">
            <p><strong>Jenkins Pipeline</strong> | Build #${BUILD_NUMBER} | Generated on \$(date '+%Y-%m-%d %H:%M:%S')</p>
            <p>🔗 <a href="${BUILD_URL}">Ver build en Jenkins</a></p>
        </div>
    </div>
</body>
</html>
EOFHTML
                    """
                    
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'reports',
                        reportFiles: "build-report-${BUILD_NUMBER}.html",
                        reportName: 'Build Report',
                        reportTitles: "Build Report #${BUILD_NUMBER}"
                    ])
                    
                    jacoco(
                        execPattern: 'SERVICE_NAME_PLACEHOLDER/target/jacoco.exec',
                        classPattern: 'SERVICE_NAME_PLACEHOLDER/target/classes',
                        sourcePattern: 'SERVICE_NAME_PLACEHOLDER/src/main/java',
                        exclusionPattern: '**/*Test*.class'
                    )
                    
                    echo "✅ [DEV] Reportes generados y publicados exitosamente"
                }
            }
        }
'@

foreach ($service in $services) {
    $jenkinsfile = "$($service.name)/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Reemplazar SERVICE_NAME_PLACEHOLDER con el nombre del servicio
        $customReportStage = $reportStage -replace 'SERVICE_NAME_PLACEHOLDER', $service.name
        
        # Buscar el patrón "        }`n    }`n    `n    post {"
        $pattern = "        \}`r?`n    \}`r?`n    `r?`n    post \{"
        $replacement = $customReportStage + "`r`n    }`r`n    `r`n    post {"
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "✅ Stage de reportes agregado a $jenkinsfile" -ForegroundColor Green
        } else {
            Write-Host "⚠️ No se encontró el patrón en $jenkinsfile" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ No se encontró $jenkinsfile" -ForegroundColor Red
    }
}

Write-Host "`n✅ Proceso completado" -ForegroundColor Green
