# Script para copiar la configuración de staging al Jenkinsfile principal
# Jenkins usa el Jenkinsfile principal y detecta la rama con BRANCH_NAME

$services = @(
    "user-service",
    "product-service", 
    "order-service",
    "payment-service",
    "shipping-service",
    "favourite-service"
)

Write-Host "🔄 Copiando configuración de staging a Jenkinsfiles principales..." -ForegroundColor Cyan
Write-Host ""

foreach ($service in $services) {
    $stagingFile = "$service/Jenkinsfile.staging"
    $mainFile = "$service/Jenkinsfile"
    
    if (Test-Path $stagingFile) {
        Write-Host "📋 Procesando $service..." -ForegroundColor Yellow
        
        # Leer el contenido del archivo staging
        $stagingContent = Get-Content $stagingFile -Raw
        
        # Crear el nuevo Jenkinsfile con detección de rama
        $newContent = @"
@Library('shared-library') _

pipeline {
    agent any
    
    environment {
        SERVICE_NAME = '$service'
        DOCKER_REGISTRY = 'gcr.io/ecommerce-435800'
        GCP_PROJECT = 'ecommerce-435800'
        GKE_CLUSTER = 'ecommerce-cluster'
        GKE_ZONE = 'us-central1-c'
    }
    
    stages {
        stage('Determine Environment') {
            steps {
                script {
                    // Detectar el ambiente basado en la rama
                    if (env.BRANCH_NAME == 'staging') {
                        env.K8S_NAMESPACE = 'ecommerce-staging'
                        env.IMAGE_TAG = "staging-\${BUILD_NUMBER}"
                        env.DEPLOY_ENV = 'staging'
                        echo "🎯 Ambiente detectado: STAGING"
                    } else if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'main') {
                        env.K8S_NAMESPACE = 'ecommerce-prod'
                        env.IMAGE_TAG = "prod-\${BUILD_NUMBER}"
                        env.DEPLOY_ENV = 'production'
                        echo "🎯 Ambiente detectado: PRODUCTION"
                    } else {
                        env.K8S_NAMESPACE = 'ecommerce-dev'
                        env.IMAGE_TAG = "dev-\${BUILD_NUMBER}"
                        env.DEPLOY_ENV = 'development'
                        echo "🎯 Ambiente detectado: DEVELOPMENT"
                    }
                    
                    env.DOCKER_IMAGE = "\${DOCKER_REGISTRY}/\${SERVICE_NAME}:\${IMAGE_TAG}"
                    
                    // Configurar puerto según el servicio
                    def servicePorts = [
                        'user-service': '8700',
                        'product-service': '8500',
                        'order-service': '8300',
                        'payment-service': '8400',
                        'shipping-service': '8600',
                        'favourite-service': '8800'
                    ]
                    env.SERVICE_PORT = servicePorts[env.SERVICE_NAME] ?: '8080'
                }
            }
        }
"@

        # Extraer los stages del archivo staging (desde el primer stage después de environment hasta el final)
        if ($stagingContent -match '(?s)stages\s*\{(.+)\}\s*post') {
            $stagesContent = $matches[1]
            
            # Agregar los stages al nuevo contenido
            $newContent += "`n        " + $stagesContent.Trim()
        }
        
        # Agregar el bloque post si existe
        if ($stagingContent -match '(?s)post\s*\{(.+)\}[\s]*\}[\s]*$') {
            $postContent = $matches[1]
            $newContent += @"
    }
    
    post {
$postContent
    }
}
"@
        } else {
            $newContent += @"
    }
}
"@
        }
        
        # Guardar el nuevo Jenkinsfile
        Set-Content -Path $mainFile -Value $newContent -NoNewline
        
        Write-Host "✅ $mainFile actualizado con configuración de staging" -ForegroundColor Green
    } else {
        Write-Host "⚠️  $stagingFile no encontrado, saltando..." -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "✅ Todos los Jenkinsfiles principales actualizados" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Ahora los Jenkinsfiles detectan automáticamente el ambiente según la rama:" -ForegroundColor Cyan
Write-Host "   - staging → ecommerce-staging namespace" -ForegroundColor Yellow
Write-Host "   - master/main → ecommerce-prod namespace" -ForegroundColor Yellow  
Write-Host "   - otras ramas → ecommerce-dev namespace" -ForegroundColor Yellow
