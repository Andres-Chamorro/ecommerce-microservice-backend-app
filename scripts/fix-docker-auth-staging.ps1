# Script para agregar autenticacion de Docker antes del pull en staging

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

Write-Host "Agregando autenticacion de Docker en stage Pull Image from Dev..." -ForegroundColor Cyan

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar y reemplazar el stage de Pull Image from Dev
        $oldPattern = @'
        stage\('Pull Image from Dev'\) \{
            steps \{
                script \{
                    echo "📥 \[STAGING\] Obteniendo imagen de DEV\.\.\."
                    def devTag = params\.DEV_BUILD_NUMBER == 'latest' \? 'dev-latest' : "dev-\$\{params\.DEV_BUILD_NUMBER\}"
                    
                    sh """
                        echo "Pulling imagen: \$\{IMAGE_NAME\}:\$\{devTag\}"
                        docker pull \$\{IMAGE_NAME\}:\$\{devTag\}
                    """
                \}
            \}
        \}
'@
        
        $newPattern = @'
        stage('Pull Image from Dev') {
            steps {
                script {
                    echo "📥 [STAGING] Obteniendo imagen de DEV..."
                    def devTag = params.DEV_BUILD_NUMBER == 'latest' ? 'dev-latest' : "dev-${params.DEV_BUILD_NUMBER}"
                    
                    sh """
                        . /root/google-cloud-sdk/path.bash.inc
                        
                        # Autenticar Docker con GCP Artifact Registry
                        echo "🔐 Autenticando Docker con GCP..."
                        gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
                        
                        echo "📥 Pulling imagen: ${IMAGE_NAME}:${devTag}"
                        docker pull ${IMAGE_NAME}:${devTag}
                    """
                }
            }
        }
'@
        
        $content = $content -replace $oldPattern, $newPattern
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "  Actualizado $jenkinsfile" -ForegroundColor Green
    } else {
        Write-Host "  $jenkinsfile no encontrado" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Completado" -ForegroundColor Green
Write-Host "Ahora Docker se autenticara antes de hacer pull de imagenes" -ForegroundColor Cyan
