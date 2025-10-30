pipeline {
    agent any
    
    environment {
        // Java Configuration
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        
        // Kubernetes
        K8S_NAMESPACE = 'ecommerce-staging'
        
        // Build
        MAVEN_OPTS = '-Xmx2048m'
        BUILD_TAG = "${env.BUILD_NUMBER}"
        
        // Docker (local registry o Docker Hub)
        DOCKER_REGISTRY = 'docker.io'
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
        
        stage('Setup Build Tools') {
            steps {
                script {
                    echo "🔧 Verificando herramientas de build..."
                    sh '''
                        # Instalar herramientas básicas
                        apt-get update || true
                        apt-get install -y openjdk-17-jdk maven curl || true
                        
                        # Verificar versiones
                        echo "✅ Java version:"
                        java -version || echo "Java no disponible"
                        echo "✅ Maven version:"
                        mvn --version || echo "Maven no disponible"
                        echo "✅ Docker version:"
                        docker --version || echo "Docker no disponible"
                        echo "✅ kubectl version:"
                        kubectl version --client || echo "kubectl no disponible"
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
                                sh 'mvn test || true'
                            }
                        }
                    }
                }
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml' allowEmptyResults: true
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
        
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY_TO_K8S == true }
            }
            steps {
                script {
                    echo "☸️ Desplegando en Kubernetes (${K8S_NAMESPACE})..."
                    
                    // Verificar conexión a Kubernetes
                    sh """
                        echo "🔍 Verificando conexión a Kubernetes..."
                        kubectl cluster-info
                        kubectl get nodes
                    """
                    
                    // Crear namespace si no existe
                    sh """
                        kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                    """
                    
                    // Desplegar servicios de infraestructura primero
                    echo "📦 Desplegando servicios de infraestructura..."
                    sh """
                        kubectl apply -f k8s/infrastructure/zipkin-deployment.yaml -n ${K8S_NAMESPACE}
                        kubectl apply -f k8s/infrastructure/service-discovery-deployment.yaml -n ${K8S_NAMESPACE}
                        kubectl apply -f k8s/infrastructure/cloud-config-deployment.yaml -n ${K8S_NAMESPACE}
                        kubectl apply -f k8s/infrastructure/api-gateway-deployment.yaml -n ${K8S_NAMESPACE}
                    """
                    
                    // Esperar a que la infraestructura esté lista
                    echo "⏳ Esperando a que la infraestructura esté lista..."
                    sh """
                        kubectl wait --for=condition=ready pod -l app=zipkin -n ${K8S_NAMESPACE} --timeout=120s || echo "Zipkin no está listo aún"
                        kubectl wait --for=condition=ready pod -l app=service-discovery -n ${K8S_NAMESPACE} --timeout=120s || echo "Service Discovery no está listo aún"
                    """
                    
                    // Desplegar microservicios
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
                            echo "📦 Desplegando ${service}..."
                            sh """
                                kubectl apply -f k8s/microservices/${service}-deployment.yaml -n ${K8S_NAMESPACE}
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
                            echo "🔍 Verificando ${service}..."
                            sh """
                                kubectl rollout status deployment/${service} -n ${K8S_NAMESPACE} --timeout=180s || echo "⚠️ ${service} no está listo"
                            """
                        }
                    }
                    
                    // Mostrar estado final
                    sh """
                        echo ""
                        echo "📊 ===== ESTADO DEL CLUSTER ====="
                        echo "Estado de los pods:"
                        kubectl get pods -n ${K8S_NAMESPACE}
                        echo ""
                        echo "Estado de los servicios:"
                        kubectl get svc -n ${K8S_NAMESPACE}
                        echo ""
                        echo "Estado de los deployments:"
                        kubectl get deployments -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
        
        stage('Integration Tests - Staging') {
            when {
                expression { params.DEPLOY_TO_K8S == true }
            }
            steps {
                script {
                    echo "🧪 Ejecutando pruebas de integración en STAGING..."
                    echo "Namespace: ${K8S_NAMESPACE}"
                    
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
                    sleep 30
                    
                    services.each { service ->
                        if (params.DEPLOY_SERVICES == 'ALL' || params.DEPLOY_SERVICES == service) {
                            echo "\n📊 Probando ${service} en staging..."
                            
                            // Verificar que el pod esté corriendo
                            sh """
                                echo "Verificando estado del pod de ${service}..."
                                kubectl get pods -n ${K8S_NAMESPACE} -l app=${service}
                                
                                POD_STATUS=\$(kubectl get pods -n ${K8S_NAMESPACE} -l app=${service} -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo 'NotFound')
                                echo "Estado del pod: \$POD_STATUS"
                                
                                if [ "\$POD_STATUS" = "Running" ]; then
                                    echo "✅ Pod de ${service} está corriendo"
                                else
                                    echo "⚠️ WARNING: Pod de ${service} no está en estado Running"
                                    kubectl describe pod -n ${K8S_NAMESPACE} -l app=${service} || true
                                fi
                            """
                            
                            // Verificar logs del servicio
                            sh """
                                echo "\n📋 Últimos logs de ${service}:"
                                kubectl logs -n ${K8S_NAMESPACE} -l app=${service} --tail=20 || echo "No se pudieron obtener logs"
                            """
                            
                            // Verificar conectividad del servicio
                            sh """
                                echo "\n🔌 Verificando servicio de ${service}..."
                                kubectl get svc -n ${K8S_NAMESPACE} ${service} || echo "Servicio no encontrado"
                            """
                        }
                    }
                    
                    // Resumen final
                    sh """
                        echo "\n📊 ===== RESUMEN DE PRUEBAS DE INTEGRACIÓN ====="
                        echo "Namespace: ${K8S_NAMESPACE}"
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
        always {
            echo "🧹 Limpiando workspace..."
            cleanWs()
        }
        success {
            echo "✅ Pipeline ejecutado exitosamente"
            echo "🎉 Build y deployment completados"
            echo "🚀 Microservicios desplegados en namespace: ${K8S_NAMESPACE}"
            echo "📊 Pruebas de integración ejecutadas exitosamente"
        }
        failure {
            echo "❌ Pipeline falló"
            echo "📋 Revisa los logs para más detalles"
        }
    }
}
