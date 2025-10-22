pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        K8S_NAMESPACE = 'ecommerce-dev'
        MAVEN_OPTS = '-Xmx2048m'
        BUILD_TAG = "${env.BUILD_NUMBER}"
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
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "Building Docker image for ${service}..."
                            sh """
                                docker build -t ecommerce-${service}:${BUILD_TAG} -f ${service}/Dockerfile .
                                docker tag ecommerce-${service}:${BUILD_TAG} ecommerce-${service}:latest
                            """
                        }
                    }
                }
            }
        }
        
        stage('Push Docker Images') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "📤 Subiendo imágenes a Docker Registry..."
                    def services = [
                        'user-service',
                        'product-service',
                        'order-service',
                        'payment-service',
                        'favourite-service',
                        'shipping-service'
                    ]
                    
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
        
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY_TO_K8S == true }
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
                expression { params.DEPLOY_TO_K8S == true }
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
                expression { params.DEPLOY_TO_K8S == true }
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
    }
    
    post {
        success {
            echo "✅ Pipeline ejecutado exitosamente"
            echo "🎉 Microservicios desplegados correctamente"
        }
        failure {
            echo "❌ Pipeline falló"
            echo "📋 Revisa los logs para más detalles"
        }
        always {
            echo "🧹 Limpiando workspace..."
            cleanWs()
        }
    }
}
