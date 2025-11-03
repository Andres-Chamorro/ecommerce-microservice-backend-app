# Script para agregar el stage de Git Tag a los Jenkinsfiles principales

Write-Host "Agregando stage de Git Tag a Jenkinsfiles principales..." -ForegroundColor Cyan
Write-Host ""

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

$gitTagStage = @'

        stage('Create Git Tag') {
            when {
                branch 'master'
            }
            steps {
                script {
                    echo "Creating Git tag for release..."
                    
                    // Get version from parameters or use default
                    def version = params.VERSION ?: '1.0.0'
                    def tagName = "${SERVICE_NAME}-v${version}"
                    
                    sh """
                        git config user.email "jenkins@ecommerce.com"
                        git config user.name "Jenkins CI"
                        
                        # Create annotated tag
                        git tag -a ${tagName} -m "Release ${SERVICE_NAME} v${version} - Build #${BUILD_NUMBER}"
                        
                        # Push tag to GitHub (triggers GitHub Actions for release notes)
                        git push origin ${tagName} || echo "Tag already exists or push failed"
                        
                        echo "Tag created: ${tagName}"
                    """
                }
            }
        }
'@

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Processing: $jenkinsfile" -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Check if Git Tag stage already exists
        if ($content -match "stage\('Create Git Tag'\)") {
            Write-Host "  Git Tag stage already exists, skipping..." -ForegroundColor Yellow
            continue
        }
        
        # Find the last stage before post section
        if ($content -match "(\s+)}\s+post\s+{") {
            # Insert before post section
            $content = $content -replace "(\s+)}\s+(post\s+{)", "`$1}$gitTagStage`n`n`$1`$2"
            
            Set-Content -Path $jenkinsfile -Value $content -NoNewline
            Write-Host "  Git Tag stage added successfully" -ForegroundColor Green
        }
        else {
            Write-Host "  Could not find insertion point (post section)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  File not found: $jenkinsfile" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Process completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Add VERSION parameter to Jenkins jobs" -ForegroundColor White
Write-Host "2. Configure Git credentials in Jenkins" -ForegroundColor White
Write-Host "3. Test by running a master branch build with VERSION parameter" -ForegroundColor White
