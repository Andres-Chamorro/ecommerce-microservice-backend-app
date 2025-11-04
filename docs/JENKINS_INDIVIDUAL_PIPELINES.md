# Configuración de Pipelines Individuales por Microservicio

## 📋 Descripción

Este proyecto ahora tiene **pipelines independientes** para cada microservicio, siguiendo las mejores prácticas de arquitectura de microservicios.

## 🎯 Ventajas de Pipelines Independientes

1. **Despliegue independiente**: Cada servicio se puede desplegar sin afectar a los demás
2. **Builds más rápidos**: Solo se compila el servicio que cambió
3. **Mejor aislamiento**: Los errores en un servicio no afectan el pipeline de otros
4. **Escalabilidad**: Fácil agregar nuevos servicios

## 📁 Estructura de Archivos

Cada microservicio ahora tiene su propio Jenkinsfile:

```
ecommerce-microservice-backend-app/
├── user-service/
│   ├── Jenkinsfile          ← Pipeline de user-service
│   ├── src/
│   └── pom.xml
├── product-service/
│   ├── Jenkinsfile          ← Pipeline de product-service
│   ├── src/
│   └── pom.xml
├── order-service/
│   ├── Jenkinsfile          ← Pipeline de order-service
│   ├── src/
│   └── pom.xml
├── payment-service/
│   ├── Jenkinsfile          ← Pipeline de payment-service
│   ├── src/
│   └── pom.xml
├── favourite-service/
│   ├── Jenkinsfile          ← Pipeline de favourite-service
│   ├── src/
│   └── pom.xml
└── shipping-service/
    ├── Jenkinsfile          ← Pipeline de shipping-service
    ├── src/
    └── pom.xml
```

## 🚀 Configuración en Jenkins

### Opción 1: Multibranch Pipeline (Recomendado)

Para cada microservicio, crea un **Multibranch Pipeline**:

1. **Ir a Jenkins** → New Item
2. **Nombre**: `user-service-pipeline` (o el nombre del servicio)
3. **Tipo**: Multibranch Pipeline
4. **Configurar**:
   - **Branch Sources**: Git
   - **Project Repository**: `https://github.com/Andres-Chamorro/ecommerce-microservice-backend-app.git`
   - **Credentials**: (tus credenciales de GitHub)
   - **Behaviors**: 
     - Discover branches
     - Filter by name (with regular expression): `staging`
   - **Build Configuration**:
     - Mode: `by Jenkinsfile`
     - Script Path: `user-service/Jenkinsfile` ← **IMPORTANTE: Ruta específica del servicio**
5. **Save**

Repite este proceso para cada microservicio:
- `user-service-pipeline` → Script Path: `user-service/Jenkinsfile`
- `product-service-pipeline` → Script Path: `product-service/Jenkinsfile`
- `order-service-pipeline` → Script Path: `order-service/Jenkinsfile`
- `payment-service-pipeline` → Script Path: `payment-service/Jenkinsfile`
- `favourite-service-pipeline` → Script Path: `favourite-service/Jenkinsfile`
- `shipping-service-pipeline` → Script Path: `shipping-service/Jenkinsfile`

### Opción 2: Pipeline Simple

Si prefieres pipelines simples (no multibranch):

1. **Ir a Jenkins** → New Item
2. **Nombre**: `user-service-pipeline`
3. **Tipo**: Pipeline
4. **Configurar**:
   - **Pipeline**:
     - Definition: `Pipeline script from SCM`
     - SCM: `Git`
     - Repository URL: `https://github.com/Andres-Chamorro/ecommerce-microservice-backend-app.git`
     - Branch: `*/staging`
     - Script Path: `user-service/Jenkinsfile`
5. **Save**

## 🔄 Flujo de Trabajo

### Para cada microservicio:

1. **Checkout**: Clona el repositorio
2. **Build Service**: Compila solo ese microservicio
3. **Unit Tests**: Ejecuta pruebas unitarias del servicio
4. **Build Docker Image**: Construye la imagen Docker
5. **Deploy to Kubernetes**: Despliega solo ese servicio en K8s
6. **Integration Tests**: Verifica que el servicio esté corriendo

## 📊 Ejemplo de Uso

### Desplegar solo user-service:

1. Ir a Jenkins → `user-service-pipeline`
2. Click en "Build with Parameters"
3. Configurar:
   - `SKIP_TESTS`: false
   - `DEPLOY_TO_K8S`: true
4. Click "Build"

### Desplegar múltiples servicios:

Ejecuta cada pipeline individualmente o usa un pipeline orquestador (ver abajo).

## 🎭 Pipeline Orquestador (Opcional)

Si necesitas desplegar todos los servicios a la vez, puedes crear un pipeline orquestador:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy All Services') {
            parallel {
                stage('User Service') {
                    steps {
                        build job: 'user-service-pipeline', wait: true
                    }
                }
                stage('Product Service') {
                    steps {
                        build job: 'product-service-pipeline', wait: true
                    }
                }
                stage('Order Service') {
                    steps {
                        build job: 'order-service-pipeline', wait: true
                    }
                }
                stage('Payment Service') {
                    steps {
                        build job: 'payment-service-pipeline', wait: true
                    }
                }
                stage('Favourite Service') {
                    steps {
                        build job: 'favourite-service-pipeline', wait: true
                    }
                }
                stage('Shipping Service') {
                    steps {
                        build job: 'shipping-service-pipeline', wait: true
                    }
                }
            }
        }
    }
}
```

## 🔧 Configuración de Webhooks (Opcional)

Para que Jenkins ejecute automáticamente el pipeline cuando haces push:

1. **En GitHub**:
   - Ir a Settings → Webhooks → Add webhook
   - Payload URL: `http://tu-jenkins-url/github-webhook/`
   - Content type: `application/json`
   - Events: `Just the push event`

2. **En Jenkins**:
   - En cada pipeline, habilitar "GitHub hook trigger for GITScm polling"

## 📝 Notas Importantes

1. **Cada pipeline es independiente**: Puedes desplegar un servicio sin afectar a los demás
2. **Mismo namespace**: Todos los servicios se despliegan en `ecommerce-staging`
3. **Imágenes Docker locales**: Las imágenes se construyen localmente (no se suben a registry)
4. **Pruebas de integración**: Cada pipeline verifica que su servicio esté corriendo correctamente

## 🎓 Para tu Taller

Esto cumple con el requisito de tu profesor:
- ✅ Un pipeline por cada microservicio
- ✅ Cada pipeline compila, prueba y despliega su propio servicio
- ✅ Pipelines independientes y desacoplados
- ✅ Pruebas de integración por servicio

## 🚨 Troubleshooting

### Error: "Script Path not found"
- Verifica que la ruta del Jenkinsfile sea correcta
- Ejemplo: `user-service/Jenkinsfile` (no `user-service\Jenkinsfile`)

### Error: "kubectl not found"
- Asegúrate de que Jenkins tenga configurado gcloud (ya lo hicimos anteriormente)

### Error: "Cannot build Docker image"
- Verifica que Docker esté corriendo en el agente de Jenkins
- Verifica que el Dockerfile esté en la carpeta del servicio
