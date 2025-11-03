# Script para agregar stage de GitHub Releases a los Jenkinsfiles

$services = @(
    "user-service",
    "order-service",
    "payment-service",
    "product-service",
    "shipping-service",
    "favourite-service"
)

Write-Host "Este script muestra cómo agregar GitHub Releases a tus pipelines" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para usar GitHub Releases necesitas:" -ForegroundColor Yellow
Write-Host "1. Instalar GitHub CLI (gh) en Jenkins" -ForegroundColor White
Write-Host "2. Configurar credenciales de GitHub en Jenkins" -ForegroundColor White
Write-Host "3. Agregar el siguiente stage después de 'Generate Release Notes':" -ForegroundColor White
Write-Host ""

$githubReleaseStage = @'
        stage('Publish to GitHub Releases') {
            steps {
                script {
                    echo "📦 [PRODUCTION] Publicando release en GitHub..."
                    
                    withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                        sh """
                            # Configurar GitHub CLI
                            export GH_TOKEN=$GITHUB_TOKEN
                            
                            # Crear release en GitHub
                            gh release create ${SERVICE_NAME}-v${params.VERSION} \
                                --title "${SERVICE_NAME} v${params.VERSION}" \
                                --notes-file releases/release-v${params.VERSION}-${SERVICE_NAME}.md \
                                --repo Andres-Chamorro/ecommerce-microservice-backend-app
                            
                            echo "✅ Release publicado en GitHub"
                        """
                    }
                }
            }
        }
'@

Write-Host $githubReleaseStage -ForegroundColor Green
Write-Host ""
Write-Host "Instalación de GitHub CLI en Jenkins:" -ForegroundColor Yellow
Write-Host "  docker exec -it jenkins bash" -ForegroundColor White
Write-Host "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg" -ForegroundColor White
Write-Host "  echo 'deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | tee /etc/apt/sources.list.d/github-cli.list" -ForegroundColor White
Write-Host "  apt update && apt install gh -y" -ForegroundColor White
