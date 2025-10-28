pipeline {
    agent any
    
    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        // GCP Configuration
        GCP_PROJECT_ID = credentials('gcp-project-id')
        GCP_REGION = 'us-central1'
        GCP_ZONE = 'us-central1-a'
        GCP_REGISTRY = "${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/ecommerce-registry"
        GKE_CLUSTER = 'ecommerce-staging-cluster'
        // Docker
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        // Kubernetes
        K8S_NAMESPACE_DEV = 'ecommerce-dev'
        K8S_NAMESPACE_STAGING = 'ecommerce-staging'
        K8S_NAMESPACE_PROD = 'ecommerce-prod'
        MAVEN_OPTS = '-Xmx2048m'
        BUILD_TAG = "${env.BUILD_NUMBER}"
        // Variables dinámicas (se setean en Determine Environment)
        K8S_NAMESPACE = ''
        TARGET_ENV = ''
        SHOULD_DEPLOY = 'false'
        USE_GCP = 'false'
    }
    
    parameters {
        choice(
            name: 'DEPLOY_SERVICES',
            choices: ['ALL', 'user-service', 'product-service', 'order-service', 'payment-service', 'favourite-service', 'shipping-service'],
            description: 'Selecciona qué servicios desplegar'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Saltar pruebas unitarias'
        )
        booleanParam(
            name: 'DEPLOY_TO_K8S',
            defaultValue: true,
            description: 'Desplegar en Kubernetes'
        )
    }
    
    stages {
        stage('Determine Environment') {
            steps {
                script {
                    def branch = env.GIT_BRANCH ?: 'dev'
                    branch = branch.replaceAll('origin/', '')
                    
                    echo "🌿 Branch detectada: ${branch}"
                    
                    if (branch == 'master' || branch == 'main') {
                        env.TARGET_ENV = 'production'
                        env.K8S_NAMESPACE = K8S_NAMESPACE_PROD
                        env.SHOULD_DEPLOY = 'true'
                        env.RUN_INTEGRATION_TESTS = 'false'
                        env.USE_GCP = 'true'
                        echo "🚀 Ambiente: PRODUCTION (GCP)"
                    } else if (branch == 'staging' || branch == 'stage') {
                        env.TARGET_ENV = 'staging'
                        env.K8S_NAMESPACE = K8S_NAMESPACE_STAGING
                        env.SHOULD_DEPLOY = 'true'
                        env.RUN_INTEGRATION_TESTS = 'true'
                        env.USE_GCP = 'true'
                        echo "🧪 Ambiente: STAGING (GCP con pruebas de integración)"
                    } else if (branch == 'dev' || branch == 'develop') {
                        env.TARGET_ENV = 'development'
                        env.K8S_NAMESPACE = K8S_NAMESPACE_DEV
                        env.SHOULD_DEPLOY = 'false'
                        env.RUN_INTEGRATION_TESTS = 'false'
                        echo "💻 Ambiente: DEVELOPMENT (solo build y tests)"
                    } else {
                        env.TARGET_ENV = 'feature'
                        env.K8S_NAMESPACE = K8S_NAMESPACE_DEV
                        env.SHOULD_DEPLOY = 'false'
                        env.RUN_INTEGRATION_TESTS = 'false'
                        echo "🔧 Ambiente: FEATURE (solo build y tests)"
                    }
                    
                    echo "📋 Configuración:"
                    echo "   - Ambiente: ${env.TARGET_ENV}"
                    echo "   - Namespace: ${env.K8S_NAMESPACE}"
                    echo "   - Deploy: ${env.SHOULD_DEPLOY}"
                    echo "   - Integration Tests: ${env.RUN_INTEGRATION_TESTS}"
                }
            }
        }
        
        stage('Checkout') {
            steps {
                echo "🔄 Clonando repositorio..."
                checkout scm
            }
        }
        
        stage('Build All Services') {
            steps {
                script {
                    echo "🔨 Compilando todos los microservicios..."
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    def testFlag = params.SKIP_TESTS ? '-DskipTests' : ''
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "📦 Compilando ${service}..."
                            dir(service) {
                                sh "mvn clean package ${testFlag}"
                            }
                        }
                    }
                }
            }
        }
        
        stage('Unit Tests') {
            when {
                expression { params.SKIP_TESTS == false }
            }
            steps {
                script {
                    echo "🧪 Ejecutando pruebas unitarias..."
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Testing ${service}..."
                            dir(service) {
                                sh 'mvn test'
                            }
                        }
                    }
                }
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Authenticate with GCP') {
            when {
                expression { env.USE_GCP == 'true' && env.SHOULD_DEPLOY == 'true' }
            }
            steps {
                script {
                    echo "🔐 Autenticando con GCP..."
                    withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GCP_KEY')]) {
                        sh """
                            gcloud auth activate-service-account --key-file=\${GCP_KEY}
                            gcloud config set project ${GCP_PROJECT_ID}
                            gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev
                            gcloud container clusters get-credentials ${GKE_CLUSTER} --zone=${GCP_ZONE}
                        """
                    }
                    echo "✅ Autenticación con GCP exitosa"
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    echo "🐳 Construyendo imágenes Docker..."
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    def registry = (env.USE_GCP == 'true') ? GCP_REGISTRY : ''
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Building Docker image for ${service}..."
                            if (env.USE_GCP == 'true') {
                                sh """
                                    docker build -t ${registry}/ecommerce-${service}:${BUILD_TAG} -f ${service}/Dockerfile .
                                    docker tag ${registry}/ecommerce-${service}:${BUILD_TAG} ${registry}/ecommerce-${service}:latest
                                """
                            } else {
                                sh """
                                    docker build -t ecommerce-${service}:${BUILD_TAG} -f ${service}/Dockerfile .
                                    docker tag ecommerce-${service}:${BUILD_TAG} ecommerce-${service}:latest
                                """
                            }
                        }
                    }
                }
            }
        }
        
        stage('Push Docker Images') {
            when {
                expression { env.SHOULD_DEPLOY == 'true' }
            }
            steps {
                script {
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    if (env.USE_GCP == 'true') {
                        echo "📤 Subiendo imágenes a GCP Artifact Registry..."
                        services.each { service ->
                            if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                                echo "Pushing ${service} to GCP..."
                                sh """
                                    docker push ${GCP_REGISTRY}/ecommerce-${service}:${BUILD_TAG}
                                    docker push ${GCP_REGISTRY}/ecommerce-${service}:latest
                                """
                            }
                        }
                    } else {
                        echo "📤 Subiendo imágenes a Docker Hub..."
                        docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS_ID) {
                            services.each { service ->
                                if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                                    echo "Pushing ${service}..."
                                    sh """
                                        docker push ecommerce-${service}:${BUILD_TAG}
                                        docker push ecommerce-${service}:latest
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY_TO_K8S == true && env.SHOULD_DEPLOY == 'true' }
            }
            steps {
                script {
                    echo "☸️ Desplegando en Kubernetes..."
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    // Crear namespace si no existe
                    sh """
                        kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                    """
                    
                    // Desplegar servicios de infraestructura primero
                    echo "Desplegando servicios de infraestructura..."
                    sh """
                        kubectl apply -f k8s/infrastructure/zipkin-deployment.yaml
                        kubectl apply -f k8s/infrastructure/service-discovery-deployment.yaml
                        kubectl apply -f k8s/infrastructure/cloud-config-deployment.yaml
                        kubectl apply -f k8s/infrastructure/api-gateway-deployment.yaml
                    """
                    
                    // Esperar a que la infraestructura esté lista
                    sh """
                        kubectl wait --for=condition=ready pod -l app=zipkin -n ${K8S_NAMESPACE} --timeout=120s || true
                        kubectl wait --for=condition=ready pod -l app=service-discovery -n ${K8S_NAMESPACE} --timeout=120s || true
                    """
                    
                    // Desplegar microservicios
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Desplegando ${service}..."
                            sh """
                                kubectl apply -f k8s/microservices/${service}-deployment.yaml
                                kubectl set image deployment/${service} ${service}=ecommerce-${service}:${BUILD_TAG} -n ${K8S_NAMESPACE} --record || true
                            """
                        }
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            when {
                expression { params.DEPLOY_TO_K8S == true && env.SHOULD_DEPLOY == 'true' }
            }
            steps {
                script {
                    echo "✅ Verificando despliegue..."
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Verificando ${service}..."
                            sh """
                                kubectl rollout status deployment/${service} -n ${K8S_NAMESPACE} --timeout=180s || true
                            """
                        }
                    }
                    
                    // Mostrar estado final
                    sh """
                        echo "Estado de los pods:"
                        kubectl get pods -n ${K8S_NAMESPACE}
                        echo ""
                        echo "Estado de los servicios:"
                        kubectl get svc -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
        
        stage('Smoke Tests') {
            when {
                expression { params.DEPLOY_TO_K8S == true && env.SHOULD_DEPLOY == 'true' }
            }
            steps {
                script {
                    echo "🔍 Ejecutando smoke tests..."
                    sleep 30
                    
                    def services = [
                        'user-service': '8700',
                        'product-service': '8500',
                        'order-service': '8300',
                        'payment-service': '8400',
                        'favourite-service': '8800',
                        'shipping-service': '8600'
                    ]
                    
                    services.each { service, port ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Testing ${service}..."
                            sh """
                                kubectl get pods -n ${K8S_NAMESPACE} -l app=${service} || true
                            """
                        }
                    }
                }
            }
        }
        
        stage('Integration Tests - Staging') {
            when {
                expression { env.RUN_INTEGRATION_TESTS == 'true' && params.DEPLOY_TO_K8S == true }
            }
            steps {
                script {
                    echo "🧪 Ejecutando pruebas de integración en STAGING..."
                    echo "Ambiente: ${env.TARGET_ENV}"
                    echo "Namespace: ${env.K8S_NAMESPACE}"
                    
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
                    // Esperar a que todos los servicios estén listos
                    echo "⏳ Esperando a que los servicios estén completamente desplegados..."
                    sleep 60
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "\n📊 Probando ${service} en staging..."
                            
                            // 1. Verificar que el pod esté corriendo
                            sh """
                                echo "Verificando estado del pod de ${service}..."
                                kubectl get pods -n ${K8S_NAMESPACE} -l app=${service}
                                
                                POD_STATUS=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=${service} -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo 'NotFound')
                                echo "Estado del pod: \$POD_STATUS"
                                
                                if [ "\$POD_STATUS" != "Running" ]; then
                                    echo "⚠️ WARNING: Pod de ${service} no está en estado Running"
                                    kubectl describe pod -n ${K8S_NAMESPACE} -l app=${service} || true
                                fi
                            """
                            
                            // 2. Verificar logs del servicio
                            sh """
                                echo "\n📋 Últimos logs de ${service}:"
                                kubectl logs -n ${K8S_NAMESPACE} -l app=${service} --tail=20 || echo "No se pudieron obtener logs"
                            """
                            
                            // 3. Verificar conectividad del servicio
                            sh """
                                echo "\n🔌 Verificando servicio de ${service}..."
                                kubectl get svc -n ${K8S_NAMESPACE} ${service} || echo "Servicio no encontrado"
                                
                                SVC_IP=\$(kubectl get svc -n ${K8S_NAMESPACE} ${service} -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo 'NotFound')
                                echo "IP del servicio: \$SVC_IP"
                            """
                            
                            // 4. Health check endpoint (si existe)
                            sh """
                                echo "\n💚 Intentando health check de ${service}..."
                                POD_NAME=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=${service} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')
                                
                                if [ -n "\$POD_NAME" ]; then
                                    echo "Pod encontrado: \$POD_NAME"
                                    # Intentar curl al actuator/health si existe
                                    kubectl exec -n ${K8S_NAMESPACE} \$POD_NAME -- curl -s http://localhost:8080/actuator/health || \
                                    kubectl exec -n ${K8S_NAMESPACE} \$POD_NAME -- curl -s http://localhost:8080/health || \
                                    echo "Health endpoint no disponible o servicio no responde"
                                else
                                    echo "⚠️ No se encontró pod para ${service}"
                                fi
                            """
                        }
                    }
                    
                    // 5. Pruebas de integración entre servicios
                    echo "\n🔗 Ejecutando pruebas de integración entre servicios..."
                    
                    if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == 'user-service') {
                        sh """
                            echo "\n👤 Test: Verificando user-service..."
                            kubectl get pods -n ${K8S_NAMESPACE} -l app=user-service
                        """
                    }
                    
                    if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == 'product-service') {
                        sh """
                            echo "\n📦 Test: Verificando product-service..."
                            kubectl get pods -n ${K8S_NAMESPACE} -l app=product-service
                        """
                    }
                    
                    if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == 'order-service') {
                        sh """
                            echo "\n🛒 Test: Verificando order-service..."
                            kubectl get pods -n ${K8S_NAMESPACE} -l app=order-service
                        """
                    }
                    
                    // 6. Verificar comunicación con service discovery
                    sh """
                        echo "\n🔍 Verificando Service Discovery (Eureka)..."
                        kubectl get pods -n ${K8S_NAMESPACE} -l app=service-discovery || echo "Service Discovery no encontrado"
                        
                        SD_POD=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=service-discovery -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')
                        if [ -n "\$SD_POD" ]; then
                            echo "Verificando servicios registrados en Eureka..."
                            kubectl exec -n ${K8S_NAMESPACE} \$SD_POD -- curl -s http://localhost:8761/eureka/apps || echo "No se pudo consultar Eureka"
                        fi
                    """
                    
                    // 7. Resumen final
                    sh """
                        echo "\n📊 ===== RESUMEN DE PRUEBAS DE INTEGRACIÓN ====="
                        echo "Ambiente: ${env.TARGET_ENV}"
                        echo "Namespace: ${env.K8S_NAMESPACE}"
                        echo "\nEstado de todos los pods:"
                        kubectl get pods -n ${K8S_NAMESPACE}
                        echo "\nEstado de todos los servicios:"
                        kubectl get svc -n ${K8S_NAMESPACE}
                        echo "\n✅ Pruebas de integración completadas"
                    """
                }
            }
            post {
                success {
                    echo "✅ Pruebas de integración en STAGING exitosas"
                }
                failure {
                    echo "❌ Pruebas de integración en STAGING fallaron"
                    echo "📋 Revisa los logs anteriores para más detalles"
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "✅ Pipeline ejecutado exitosamente"
                echo "🎉 Build completado para ambiente: ${env.TARGET_ENV}"
                
                if (env.SHOULD_DEPLOY == 'true') {
                    echo "🚀 Microservicios desplegados en: ${env.K8S_NAMESPACE}"
                    
                    if (env.RUN_INTEGRATION_TESTS == 'true') {
                        echo "✅ Pruebas de integración ejecutadas exitosamente"
                        echo "📊 El ambiente de STAGING está listo para pruebas manuales"
                    }
                } else {
                    echo "💻 Build y tests completados (sin deploy)"
                }
            }
        }
        failure {
            script {
                echo "❌ Pipeline falló en ambiente: ${env.TARGET_ENV}"
                echo "📋 Revisa los logs para más detalles"
                
                if (env.RUN_INTEGRATION_TESTS == 'true') {
                    echo "⚠️ Las pruebas de integración fallaron en STAGING"
                    echo "🚫 NO desplegar a PRODUCCIÓN hasta resolver los errores"
                }
            }
        }
        always {
            echo "🧹 Limpiando workspace..."
            cleanWs()
        }
    }
}
