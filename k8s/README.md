# 📁 Estructura de Kubernetes

Esta carpeta contiene todos los manifiestos de Kubernetes organizados por tipo de servicio.

## 🗂️ Estructura de Carpetas

```
k8s/
├── base/                           # Configuración base
│   └── namespace.yaml             # Namespace ecommerce-dev
│
├── infrastructure/                 # Servicios de infraestructura (Patrones)
│   ├── zipkin-deployment.yaml     # Distributed Tracing
│   ├── service-discovery-deployment.yaml  # Eureka Server
│   ├── cloud-config-deployment.yaml       # Config Server
│   └── api-gateway-deployment.yaml        # API Gateway
│
├── microservices/                  # Microservicios de negocio
│   ├── user-service-deployment.yaml
│   ├── product-service-deployment.yaml
│   ├── order-service-deployment.yaml
│   ├── payment-service-deployment.yaml
│   ├── favourite-service-deployment.yaml
│   └── shipping-service-deployment.yaml
│
├── deploy-all.sh                   # Script de despliegue (Linux/Mac)
├── deploy-all.ps1                  # Script de despliegue (Windows)
├── delete-all.sh                   # Script de limpieza (Linux/Mac)
├── delete-all.ps1                  # Script de limpieza (Windows)
└── README.md                       # Este archivo
```

---

## 📦 Categorías de Servicios

### 🏗️ Base (`base/`)
Contiene la configuración fundamental del cluster:
- **namespace.yaml**: Define el namespace `ecommerce-dev` donde se despliegan todos los servicios

### 🔧 Infrastructure (`infrastructure/`)
Servicios de infraestructura que implementan patrones de microservicios:

| Servicio | Puerto | Descripción | Patrón |
|----------|--------|-------------|--------|
| **zipkin** | 9411 | Distributed Tracing | Observabilidad |
| **service-discovery** | 8761 | Eureka Server | Service Registry |
| **cloud-config** | 9296 | Config Server | Configuración Centralizada |
| **api-gateway** | 8080 | API Gateway | Punto de Entrada Único |

### 🚀 Microservices (`microservices/`)
Microservicios de negocio de la aplicación:

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **user-service** | 8700 | Gestión de usuarios |
| **product-service** | 8500 | Gestión de productos |
| **order-service** | 8300 | Gestión de pedidos |
| **payment-service** | 8400 | Procesamiento de pagos |
| **favourite-service** | 8800 | Lista de favoritos |
| **shipping-service** | 8600 | Gestión de envíos |

---

## 🚀 Despliegue

### Despliegue Completo

**Windows:**
```powershell
cd k8s
.\deploy-all.ps1
```

**Linux/Mac:**
```bash
cd k8s
chmod +x deploy-all.sh
./deploy-all.sh
```

### Despliegue Manual por Categorías

#### 1. Crear Namespace
```bash
kubectl apply -f base/namespace.yaml
```

#### 2. Desplegar Infraestructura
```bash
kubectl apply -f infrastructure/
```

#### 3. Desplegar Microservicios
```bash
kubectl apply -f microservices/
```

### Despliegue de un Servicio Específico

```bash
# Ejemplo: Desplegar solo user-service
kubectl apply -f microservices/user-service-deployment.yaml

# Ejemplo: Desplegar solo API Gateway
kubectl apply -f infrastructure/api-gateway-deployment.yaml
```

---

## 🔍 Verificación

### Ver todos los recursos
```bash
kubectl get all -n ecommerce-dev
```

### Ver pods por categoría
```bash
# Infraestructura
kubectl get pods -n ecommerce-dev -l tier=infrastructure

# Microservicios
kubectl get pods -n ecommerce-dev -l tier=microservice
```

### Ver servicios
```bash
kubectl get svc -n ecommerce-dev
```

### Ver deployments
```bash
kubectl get deployments -n ecommerce-dev
```

---

## 🧹 Limpieza

### Eliminar todos los recursos

**Windows:**
```powershell
.\delete-all.ps1
```

**Linux/Mac:**
```bash
./delete-all.sh
```

### Eliminar por categorías

```bash
# Eliminar solo microservicios
kubectl delete -f microservices/

# Eliminar solo infraestructura
kubectl delete -f infrastructure/

# Eliminar namespace (esto elimina TODO)
kubectl delete namespace ecommerce-dev
```

---

## 📊 Orden de Despliegue

El orden correcto de despliegue es importante para las dependencias:

1. **Base** → Namespace
2. **Infrastructure** → Zipkin, Service Discovery, Cloud Config
3. **Infrastructure** → API Gateway (después de que los anteriores estén listos)
4. **Microservices** → Todos los microservicios de negocio

Los scripts `deploy-all.*` ya implementan este orden automáticamente.

---

## 🔄 Actualización de Servicios

### Actualizar imagen de un servicio
```bash
kubectl set image deployment/user-service \
  user-service=ecommerce-user-service:v2.0 \
  -n ecommerce-dev
```

### Reiniciar un deployment
```bash
kubectl rollout restart deployment/user-service -n ecommerce-dev
```

### Ver historial de despliegues
```bash
kubectl rollout history deployment/user-service -n ecommerce-dev
```

### Rollback a versión anterior
```bash
kubectl rollout undo deployment/user-service -n ecommerce-dev
```

---

## 🌐 Acceso a los Servicios

### Port-Forward para acceso local

```bash
# API Gateway (punto de entrada principal)
kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev

# Eureka Dashboard
kubectl port-forward svc/service-discovery 8761:8761 -n ecommerce-dev

# Zipkin Dashboard
kubectl port-forward svc/zipkin 9411:9411 -n ecommerce-dev

# Microservicio específico
kubectl port-forward svc/user-service 8700:8700 -n ecommerce-dev
```

### URLs de Acceso
- **API Gateway**: http://localhost:8080
- **Eureka**: http://localhost:8761
- **Zipkin**: http://localhost:9411

---

## 🔧 Troubleshooting

### Ver logs de un servicio
```bash
kubectl logs -f deployment/user-service -n ecommerce-dev
```

### Describir un pod con problemas
```bash
kubectl describe pod <pod-name> -n ecommerce-dev
```

### Ver eventos del namespace
```bash
kubectl get events -n ecommerce-dev --sort-by='.lastTimestamp'
```

### Ejecutar comando dentro de un pod
```bash
kubectl exec -it <pod-name> -n ecommerce-dev -- /bin/sh
```

---

## 📝 Configuración de Recursos

Todos los deployments incluyen:
- ✅ **Replicas**: 2 (excepto service-discovery y cloud-config: 1)
- ✅ **Resources**: Requests y Limits definidos
- ✅ **Liveness Probe**: Para detectar si el contenedor está vivo
- ✅ **Readiness Probe**: Para saber cuándo está listo para recibir tráfico
- ✅ **Environment Variables**: Configuración de Spring Boot
- ✅ **Labels**: Para organización y selección

---

## 🎯 Buenas Prácticas Implementadas

1. **Separación de Concerns**: Infraestructura vs Microservicios
2. **Namespace Dedicado**: Aislamiento de recursos
3. **Health Checks**: Liveness y Readiness probes
4. **Resource Limits**: CPU y memoria definidos
5. **Labels Consistentes**: Para filtrado y organización
6. **Service Discovery**: Comunicación entre servicios
7. **Centralized Config**: Configuración desde Config Server
8. **Distributed Tracing**: Observabilidad con Zipkin

---

## 🚀 Integración con CI/CD

El Jenkinsfile en la raíz del proyecto ya está configurado para usar esta estructura:

```groovy
// Desplegar infraestructura
kubectl apply -f k8s/infrastructure/

// Desplegar microservicios
kubectl apply -f k8s/microservices/
```

---

**¡Estructura organizada y lista para producción!** 🎉
