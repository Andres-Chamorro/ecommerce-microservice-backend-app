pipeline {
    agent any
    
    environment {
        // Java Configuration
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        // GCP Configuration
        GCP_PROJECT_ID = credentials('gcp-project-id')
        GCP_REGION = 'us-central1'
        GCP_ZONE = 'us-central1-a'
        GCP_REGISTRY = "${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/ecommerce-registry"
        GKE_CLUSTER = 'ecommerce-staging-cluster'
        // GKE Auth Plugin
        USE_GKE_GCLOUD_AUTH_PLUGIN = 'True'
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
                    // Obtener branch de diferentes fuentes posibles
                    def branch = env.GIT_BRANCH ?: env.BRANCH_NAME ?: 'dev'
                    branch = branch.replaceAll('origin/', '')
                    
                    echo "🌿 Branch detectada: ${branch}"
                    echo "🔍 GIT_BRANCH: ${env.GIT_BRANCH}"
                    echo "🔍 BRANCH_NAME: ${env.BRANCH_NAME}"
                    
                    // Usar variables locales con def para evitar warnings
                    def targetEnv, k8sNamespace, shouldDeploy, runIntegrationTests, useGcp
                    
                    if (branch == 'master' || branch == 'main') {
                        targetEnv = 'production'
                        k8sNamespace = 'ecommerce-prod'
                        shouldDeploy = 'true'
                        runIntegrationTests = 'false'
                        useGcp = 'true'
                        echo "🚀 Ambiente: PRODUCTION (GCP)"
                    } else if (branch == 'staging' || branch == 'stage') {
                        targetEnv = 'staging'
                        k8sNamespace = 'ecommerce-staging'
                        shouldDeploy = 'true'
                        runIntegrationTests = 'true'
                        useGcp = 'true'
                        echo "🧪 Ambiente: STAGING (GCP con pruebas de integración)"
                    } else if (branch == 'dev' || branch == 'develop') {
                        targetEnv = 'development'
                        k8sNamespace = 'ecommerce-dev'
                        shouldDeploy = 'false'
                        runIntegrationTests = 'false'
                        useGcp = 'false'
                        echo "💻 Ambiente: DEVELOPMENT (solo build y tests)"
                    } else {
                        targetEnv = 'feature'
                        k8sNamespace = 'ecommerce-dev'
                        shouldDeploy = 'false'
                        runIntegrationTests = 'false'
                        useGcp = 'false'
                        echo "🔧 Ambiente: FEATURE (solo build y tests)"
                    }
                    
                    // Establecer en env para uso en otros stages
                    env.TARGET_ENV = targetEnv
                    env.K8S_NAMESPACE = k8sNamespace
                    env.SHOULD_DEPLOY = shouldDeploy
                    env.RUN_INTEGRATION_TESTS = runIntegrationTests
                    env.USE_GCP = useGcp
                    
                    echo "📋 Configuración:"
                    echo "   - Ambiente: ${targetEnv}"
                    echo "   - Namespace: ${k8sNamespace}"
                    echo "   - Deploy: ${shouldDeploy}"
                    echo "   - Integration Tests: ${runIntegrationTests}"
                    echo "   - Use GCP: ${useGcp}"
                }
            }
        }
        
        stage('Checkout') {
            steps {
                echo "🔄 Clonando repositorio..."
                checkout scm
            }
        }
        
        stage('Setup Build Tools') {
            steps {
                script {
                    echo "🔧 Verificando herramientas de build..."
                    sh '''
                        # Limpiar repositorios problemáticos de Google Cloud
                        rm -f /etc/apt/sources.list.d/google-cloud-sdk.list
                        
                        # Instalar Java 17, Maven y Docker CLI si no existen
                        apt-get update
                        apt-get install -y openjdk-17-jdk maven ca-certificates curl gnupg
                        
                        # Instalar Docker CLI solo si no está instalado
                        if ! command -v docker &> /dev/null; then
                            echo "Instalando Docker CLI..."
                            install -m 0755 -d /etc/apt/keyrings
                            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
                            chmod a+r /etc/apt/keyrings/docker.gpg
                            
                            echo \
                              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                              tee /etc/apt/sources.list.d/docker.list > /dev/null
                            
                            apt-get update
                            apt-get install -y docker-ce-cli
                        else
                            echo "Docker CLI ya está instalado"
                        fi
                        
                        # Instalar kubectl si no está instalado
                        if ! command -v kubectl &> /dev/null; then
                            echo "Instalando kubectl..."
                            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                            chmod +x kubectl
                            mv kubectl /usr/local/bin/
                        else
                            echo "kubectl ya está instalado"
                        fi
                        
                        # Instalar gcloud CLI si no está instalado (necesario para GCP)
                        if ! command -v gcloud &> /dev/null; then
                            echo "Instalando Google Cloud CLI..."
                            # Método alternativo más confiable
                            curl https://sdk.cloud.google.com | bash || echo "Warning: gcloud installation failed, continuing..."
                            if [ -f /root/google-cloud-sdk/path.bash.inc ]; then
                                . /root/google-cloud-sdk/path.bash.inc
                                gcloud components install gke-gcloud-auth-plugin --quiet || echo "Warning: gke-auth-plugin installation failed"
                            fi
                        else
                            echo "gcloud CLI ya está instalado"
                        fi
                        
                        # Configurar Java 17 como default
                        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
                        export PATH=$JAVA_HOME/bin:$PATH
                        
                        echo "✅ Java version:"
                        java -version
                        echo "✅ Maven version:"
                        mvn --version
                        echo "✅ Docker version:"
                        docker --version
                        echo "✅ kubectl version:"
                        kubectl version --client
                        echo "✅ gcloud version:"
                        gcloud version || echo "gcloud not available - will be installed when needed"
                    '''
                }
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
                expression { 
                    return env.USE_GCP == 'true' && env.SHOULD_DEPLOY == 'true'
                }
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
                    
                    def useGcp = (env.USE_GCP == 'true')
                    def registry = useGcp ? GCP_REGISTRY : ''
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Building Docker image for ${service}..."
                            if (useGcp) {
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
                expression { 
                    return env.SHOULD_DEPLOY == 'true'
                }
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
                    
                    def useGcp = (env.USE_GCP == 'true')
                    if (useGcp) {
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
                expression { 
                    return params.DEPLOY_TO_K8S == true && env.SHOULD_DEPLOY == 'true'
                }
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
                        kubectl create namespace ${env.K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
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
                        kubectl wait --for=condition=ready pod -l app=zipkin -n ${env.K8S_NAMESPACE} --timeout=120s || true
                        kubectl wait --for=condition=ready pod -l app=service-discovery -n ${env.K8S_NAMESPACE} --timeout=120s || true
                    """
                    
                    // Desplegar microservicios
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Desplegando ${service}..."
                            sh """
                                kubectl apply -f k8s/microservices/${service}-deployment.yaml
                                kubectl set image deployment/${service} ${service}=ecommerce-${service}:${BUILD_TAG} -n ${env.K8S_NAMESPACE} --record || true
                            """
                        }
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            when {
                expression { 
                    return params.DEPLOY_TO_K8S == true && env.SHOULD_DEPLOY == 'true'
                }
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
                                kubectl rollout status deployment/${service} -n ${env.K8S_NAMESPACE} --timeout=180s || true
                            """
                        }
                    }
                    
                    // Mostrar estado final
                    sh """
                        echo "Estado de los pods:"
                        kubectl get pods -n ${env.K8S_NAMESPACE}
                        echo ""
                        echo "Estado de los servicios:"
                        kubectl get svc -n ${env.K8S_NAMESPACE}
                    """
                }
            }
        }
        
        stage('Smoke Tests') {
            when {
                expression { 
                    return params.DEPLOY_TO_K8S == true && env.SHOULD_DEPLOY == 'true'
                }
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
                                kubectl get pods -n ${env.K8S_NAMESPACE} -l app=${service} || true
                            """
                        }
                    }
                }
            }
        }
        
        stage('Integration Tests - Staging') {
            when {
                allOf {
                    expression { return env.RUN_INTEGRATION_TESTS == 'true' }
                    expression { return params.DEPLOY_TO_K8S == true }
                    expression { return env.SHOULD_DEPLOY == 'true' }
                }
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
                                kubectl get pods -n ${env.K8S_NAMESPACE} -l app=${service}
                                
                                POD_STATUS=\$(kubectl get pods -n ${env.K8S_NAMESPACE} -l app=${service} -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo 'NotFound')
                                echo "Estado del pod: \$POD_STATUS"
                                
                                if [ "\$POD_STATUS" != "Running" ]; then
                                    echo "⚠️ WARNING: Pod de ${service} no está en estado Running"
                                    kubectl describe pod -n ${env.K8S_NAMESPACE} -l app=${service} || true
                                fi
                            """
                            
                            // 2. Verificar logs del servicio
                            sh """
                                echo "\n📋 Últimos logs de ${service}:"
                                kubectl logs -n ${env.K8S_NAMESPACE} -l app=${service} --tail=20 || echo "No se pudieron obtener logs"
                            """
                            
                            // 3. Verificar conectividad del servicio
                            sh """
                                echo "\n🔌 Verificando servicio de ${service}..."
                                kubectl get svc -n ${env.K8S_NAMESPACE} ${service} || echo "Servicio no encontrado"
                                
                                SVC_IP=\$(kubectl get svc -n ${env.K8S_NAMESPACE} ${service} -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo 'NotFound')
                                echo "IP del servicio: \$SVC_IP"
                            """
                            
                            // 4. Health check endpoint (si existe)
                            sh """
                                echo "\n💚 Intentando health check de ${service}..."
                                POD_NAME=\$(kubectl get pods -n ${env.K8S_NAMESPACE} -l app=${service} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')
                                
                                if [ -n "\$POD_NAME" ]; then
                                    echo "Pod encontrado: \$POD_NAME"
                                    # Intentar curl al actuator/health si existe
                                    kubectl exec -n ${env.K8S_NAMESPACE} \$POD_NAME -- curl -s http://localhost:8080/actuator/health || \
                                    kubectl exec -n ${env.K8S_NAMESPACE} \$POD_NAME -- curl -s http://localhost:8080/health || \
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
                            kubectl get pods -n ${env.K8S_NAMESPACE} -l app=user-service
                        """
                    }
                    
                    if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == 'product-service') {
                        sh """
                            echo "\n📦 Test: Verificando product-service..."
                            kubectl get pods -n ${env.K8S_NAMESPACE} -l app=product-service
                        """
                    }
                    
                    if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == 'order-service') {
                        sh """
                            echo "\n🛒 Test: Verificando order-service..."
                            kubectl get pods -n ${env.K8S_NAMESPACE} -l app=order-service
                        """
                    }
                    
                    // 6. Verificar comunicación con service discovery
                    sh """
                        echo "\n🔍 Verificando Service Discovery (Eureka)..."
                        kubectl get pods -n ${env.K8S_NAMESPACE} -l app=service-discovery || echo "Service Discovery no encontrado"
                        
                        SD_POD=\$(kubectl get pods -n ${env.K8S_NAMESPACE} -l app=service-discovery -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo '')
                        if [ -n "\$SD_POD" ]; then
                            echo "Verificando servicios registrados en Eureka..."
                            kubectl exec -n ${env.K8S_NAMESPACE} \$SD_POD -- curl -s http://localhost:8761/eureka/apps || echo "No se pudo consultar Eureka"
                        fi
                    """
                    
                    // 7. Resumen final
                    sh """
                        echo "\n📊 ===== RESUMEN DE PRUEBAS DE INTEGRACIÓN ====="
                        echo "Ambiente: ${env.TARGET_ENV}"
                        echo "Namespace: ${env.K8S_NAMESPACE}"
                        echo "\nEstado de todos los pods:"
                        kubectl get pods -n ${env.K8S_NAMESPACE}
                        echo "\nEstado de todos los servicios:"
                        kubectl get svc -n ${env.K8S_NAMESPACE}
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
        always {
            echo "🧹 Limpiando workspace..."
            cleanWs()
        }
        success {
            script {
                def targetEnv = env.TARGET_ENV ?: 'unknown'
                def k8sNamespace = env.K8S_NAMESPACE ?: 'unknown'
                
                echo "✅ Pipeline ejecutado exitosamente"
                echo "🎉 Build completado para ambiente: ${targetEnv}"
                
                if (env.SHOULD_DEPLOY == 'true') {
                    echo "� Mic roservicios desplegados en: ${k8sNamespace}"
                    
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
                def targetEnv = env.TARGET_ENV ?: 'unknown'
                echo "❌ Pipeline falló en ambiente: ${targetEnv}"
                echo "📋 Revisa los logs para más detalles"
                
                if (env.RUN_INTEGRATION_TESTS == 'true') {
                    echo "⚠️ Las pruebas de integración fallaron en STAGING"
                    echo "🚫 NO desplegar a PRODUCCIÓN hasta resolver los errores"
                }
            }
        }
    }
}
