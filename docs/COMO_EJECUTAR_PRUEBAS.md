# 🧪 Guía de Ejecución de Pruebas

## 📋 Tabla de Contenidos
- [Script Automatizado](#script-automatizado)
- [Pruebas Individuales](#pruebas-individuales)
- [Requisitos Previos](#requisitos-previos)
- [Solución de Problemas](#solución-de-problemas)

---

## 🚀 Script Automatizado

### Ejecutar TODAS las pruebas (83 pruebas)

```powershell
# En la raíz del proyecto
.\run-all-tests.ps1
```

### ¿Qué hace el script?

El script ejecuta automáticamente:

1. ✅ **48 Pruebas Unitarias** (6 microservicios)
2. ✅ **12 Pruebas de Integración** (4 suites)
3. ✅ **23 Pruebas E2E** (4 suites)
4. ✅ **Configuración de Locust** (Rendimiento)

### Salida Esperada

```
======================================
Ejecutando Suite Completa de Pruebas
Ecommerce Microservices - 83 Pruebas
======================================

[1/4] Ejecutando Pruebas Unitarias (48 pruebas)...
---------------------------------------------------

User Service (12 pruebas):
  ✓ UserServiceTest (6 pruebas) - PASSED
  ✓ UserResourceTest (6 pruebas) - PASSED

Product Service (13 pruebas):
  ✓ ProductServiceTest (7 pruebas) - PASSED
  ✓ ProductResourceTest (6 pruebas) - PASSED

...

======================================
Resumen de Resultados
======================================

🎉 ¡Todas las pruebas pasaron exitosamente!

Total de pruebas individuales: 83
  - 48 pruebas unitarias ✓
  - 12 pruebas de integración ✓
  - 23 pruebas E2E ✓
```

---

## 🎯 Pruebas Individuales

### 1️⃣ Pruebas Unitarias (48 pruebas)

#### User Service (12 pruebas)
```bash
cd user-service
mvn test -Dtest=UserServiceTest      # 6 pruebas
mvn test -Dtest=UserResourceTest     # 6 pruebas
```

#### Product Service (13 pruebas)
```bash
cd product-service
mvn test -Dtest=ProductServiceTest   # 7 pruebas
mvn test -Dtest=ProductResourceTest  # 6 pruebas
```

#### Order Service (7 pruebas)
```bash
cd order-service
mvn test -Dtest=OrderServiceTest     # 7 pruebas
```

#### Payment Service (8 pruebas)
```bash
cd payment-service
mvn test -Dtest=PaymentServiceTest   # 8 pruebas
```

#### Shipping Service (6 pruebas)
```bash
cd shipping-service
mvn test -Dtest=ShippingServiceTest  # 6 pruebas
```

#### Favourite Service (8 pruebas)
```bash
cd favourite-service
mvn test -Dtest=FavouriteServiceTest # 8 pruebas
```

---

### 2️⃣ Pruebas de Integración (12 pruebas)

**Requisito**: Servicios deben estar corriendo en Kubernetes

```bash
# Verificar servicios
kubectl get pods -n ecommerce-dev

# Ejecutar pruebas
cd tests/integration
mvn test -Dtest=UserOrderIntegrationTest        # 3 pruebas
mvn test -Dtest=OrderPaymentIntegrationTest     # 3 pruebas
mvn test -Dtest=ProductFavouriteIntegrationTest # 3 pruebas
mvn test -Dtest=OrderShippingIntegrationTest    # 3 pruebas
```

---

### 3️⃣ Pruebas E2E (23 pruebas)

**Requisito**: Sistema completo debe estar corriendo

```bash
cd tests/e2e
mvn test -Dtest=CompleteUserJourneyE2ETest  # 8 pruebas
mvn test -Dtest=ProductCatalogE2ETest       # 3 pruebas
mvn test -Dtest=AdminOperationsE2ETest      # 6 pruebas
mvn test -Dtest=ErrorHandlingE2ETest        # 6 pruebas
```

---

### 4️⃣ Pruebas de Rendimiento (Locust)

#### Instalación
```bash
cd tests/performance
pip install -r requirements.txt
```

#### Ejecución
```bash
locust -f locustfile.py --host=http://localhost:8080
```

Luego abre en el navegador: **http://localhost:8089**

#### Configuración Recomendada
- **Usuarios**: 100
- **Spawn rate**: 10 usuarios/segundo
- **Duración**: 5 minutos

---

## 📋 Requisitos Previos

### Para Pruebas Unitarias
✅ Java 17+  
✅ Maven 3.8+  

```bash
java -version
mvn -version
```

### Para Pruebas de Integración
✅ Kubernetes cluster corriendo  
✅ Servicios desplegados en namespace `ecommerce-dev`  

```bash
kubectl get pods -n ecommerce-dev
```

### Para Pruebas E2E
✅ Todos los servicios corriendo  
✅ API Gateway accesible en `http://localhost:8080`  

```bash
curl http://localhost:8080/actuator/health
```

### Para Pruebas de Rendimiento
✅ Python 3.8+  
✅ Locust instalado  

```bash
python --version
pip show locust
```

---

## 🔧 Solución de Problemas

### Error: "mvn: command not found"
```bash
# Instalar Maven
# Windows: choco install maven
# Mac: brew install maven
# Linux: sudo apt install maven
```

### Error: "kubectl: command not found"
```bash
# Instalar kubectl
# Windows: choco install kubernetes-cli
# Mac: brew install kubectl
# Linux: sudo apt install kubectl
```

### Error: Pruebas de integración fallan
```bash
# Verificar que los servicios estén corriendo
kubectl get pods -n ecommerce-dev

# Si no están corriendo, desplegarlos
kubectl apply -f k8s/
```

### Error: "Connection refused" en pruebas E2E
```bash
# Verificar que el API Gateway esté corriendo
kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce-dev
```

### Error: Locust no se instala
```bash
# Actualizar pip
python -m pip install --upgrade pip

# Instalar Locust manualmente
pip install locust
```

---

## 📊 Reportes de Pruebas

### Ver reportes HTML
```bash
# Generar reporte de pruebas
mvn surefire-report:report

# Ver en: target/site/surefire-report.html
```

### Ver cobertura de código
```bash
# Generar reporte de cobertura
mvn jacoco:report

# Ver en: target/site/jacoco/index.html
```

### Ver todos los reportes
```bash
# Generar sitio completo
mvn site

# Ver en: target/site/index.html
```

---

## 🎯 Comandos Rápidos

### Solo pruebas unitarias
```powershell
# Ejecutar todas las unitarias de todos los servicios
foreach ($service in @("user-service", "product-service", "order-service", "payment-service", "shipping-service", "favourite-service")) {
    cd $service
    mvn test
    cd ..
}
```

### Solo pruebas que no requieren servicios externos
```bash
# Pruebas unitarias (no necesitan servicios corriendo)
mvn test
```

### Ejecutar con logs detallados
```bash
mvn test -X  # Modo debug
```

### Ejecutar sin compilar
```bash
mvn surefire:test  # Solo ejecuta pruebas
```

---

## 📈 Métricas Esperadas

| Tipo de Prueba | Cantidad | Tiempo Aprox. |
|----------------|----------|---------------|
| Pruebas Unitarias | 48 | ~30 segundos |
| Pruebas de Integración | 12 | ~2 minutos |
| Pruebas E2E | 23 | ~5 minutos |
| **TOTAL** | **83** | **~7-8 minutos** |

---

## ✅ Checklist de Ejecución

Antes de ejecutar el script completo:

- [ ] Java 17+ instalado
- [ ] Maven 3.8+ instalado
- [ ] Kubernetes cluster corriendo (para integración)
- [ ] Servicios desplegados (para E2E)
- [ ] Python 3.8+ instalado (para Locust)
- [ ] Puertos disponibles (8080, 8089)

---

## 🎓 Para el Taller

### Demostración Rápida (Solo Unitarias)
```bash
# Ejecutar solo pruebas unitarias (30 segundos)
cd user-service && mvn test && cd ..
cd product-service && mvn test && cd ..
```

### Demostración Completa
```powershell
# Ejecutar todo el script (7-8 minutos)
.\run-all-tests.ps1
```

---

**¡Listo para ejecutar!** 🚀

*Última actualización: 25 de Octubre, 2025*
