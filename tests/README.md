# 🧪 Guía Completa de Pruebas

Este directorio contiene todas las pruebas del sistema: unitarias, integración, E2E y rendimiento.

## 📁 Estructura de Pruebas

```
tests/
├── integration/                    # Pruebas de integración entre servicios
│   ├── UserOrderIntegrationTest.java
│   └── OrderPaymentIntegrationTest.java
│
├── e2e/                           # Pruebas End-to-End
│   ├── CompleteUserJourneyE2ETest.java
│   └── ProductCatalogE2ETest.java
│
├── performance/                    # Pruebas de rendimiento
│   ├── locustfile.py
│   └── requirements.txt
│
└── README.md                       # Esta guía
```

---

## ✅ Pruebas Implementadas

### 🔹 Pruebas Unitarias (6 pruebas)

**Ubicación**: `user-service/src/test/java/com/selimhorri/app/`

#### UserServiceTest.java (Service Layer)
1. ✅ **testFindAll_ShouldReturnAllUsers** - Valida obtención de todos los usuarios
2. ✅ **testFindById_ShouldReturnUser_WhenUserExists** - Valida búsqueda por ID
3. ✅ **testSave_ShouldCreateNewUser** - Valida creación de usuario
4. ✅ **testUpdate_ShouldUpdateExistingUser** - Valida actualización de usuario
5. ✅ **testDeleteById_ShouldDeleteUser** - Valida eliminación de usuario
6. ✅ **testFindByUsername_ShouldReturnUser_WhenUsernameExists** - Valida búsqueda por username

#### UserResourceTest.java (Controller Layer)
1. ✅ **testFindAll_ShouldReturnUsersList** - Valida endpoint GET /api/users
2. ✅ **testFindById_ShouldReturnUser** - Valida endpoint GET /api/users/{id}
3. ✅ **testSave_ShouldCreateNewUser** - Valida endpoint POST /api/users
4. ✅ **testUpdate_ShouldUpdateUser** - Valida endpoint PUT /api/users
5. ✅ **testDeleteById_ShouldDeleteUser** - Valida endpoint DELETE /api/users/{id}
6. ✅ **testFindByUsername_ShouldReturnUser** - Valida endpoint GET /api/users/username/{username}

---

### 🔹 Pruebas de Integración (6 pruebas)

**Ubicación**: `tests/integration/`

#### UserOrderIntegrationTest.java
1. ✅ **testCreateUserAndPlaceOrder** - Valida creación de usuario y pedido
2. ✅ **testUserCanHaveMultipleOrders** - Valida relación 1:N entre User y Orders
3. ✅ **testReferentialIntegrityBetweenUserAndOrder** - Valida integridad referencial

#### OrderPaymentIntegrationTest.java
4. ✅ **testCreateOrderAndProcessPayment** - Valida flujo Order → Payment
5. ✅ **testOrderWithoutPaymentIsPending** - Valida estado de pedido sin pago
6. ✅ **testRejectedPaymentKeepsOrderPending** - Valida manejo de pagos rechazados

---

### 🔹 Pruebas End-to-End (11 pruebas)

**Ubicación**: `tests/e2e/`

#### CompleteUserJourneyE2ETest.java
1. ✅ **testUserRegistration** - Registro completo de usuario
2. ✅ **testProductSearch** - Búsqueda y selección de productos
3. ✅ **testAddProductToFavourites** - Agregar productos a favoritos
4. ✅ **testCreateOrder** - Creación de pedido
5. ✅ **testProcessPayment** - Procesamiento de pago
6. ✅ **testCreateShipping** - Creación de envío
7. ✅ **testVerifyUserHistory** - Verificación de historial completo
8. ✅ **testProductReturnFlow** - Flujo de devolución de producto

#### ProductCatalogE2ETest.java
9. ✅ **testListAllProducts** - Listar catálogo completo
10. ✅ **testSearchAndViewProductDetails** - Búsqueda y visualización de detalles
11. ✅ **testUpdateProductInformation** - Actualización de información de producto

---

### 🔹 Pruebas de Rendimiento (Locust)

**Ubicación**: `tests/performance/locustfile.py`

#### Escenarios Implementados:

1. **UserBehavior (SequentialTaskSet)**
   - Simula flujo completo de usuario
   - 7 tareas secuenciales: registro → navegación → favoritos → pedido → pago → envío

2. **ReadOnlyUser**
   - Simula usuarios que solo navegan (60% del tráfico)
   - Operaciones de solo lectura

3. **BuyerUser**
   - Simula usuarios que compran (40% del tráfico)
   - Flujo completo de compra

4. **StressTestUser**
   - Para pruebas de estrés
   - Operaciones rápidas y concurrentes

---

## 🚀 Ejecución de Pruebas

### 1️⃣ Pruebas Unitarias

```bash
# Ejecutar todas las pruebas unitarias
cd user-service
mvn test

# Ejecutar una clase específica
mvn test -Dtest=UserServiceTest

# Ejecutar con reporte de cobertura
mvn test jacoco:report
```

### 2️⃣ Pruebas de Integración

```bash
# Asegurarse de que los servicios estén corriendo
cd k8s
.\deploy-all.ps1

# Ejecutar pruebas de integración
mvn verify -P integration-tests

# O ejecutar clases específicas
mvn test -Dtest=UserOrderIntegrationTest
mvn test -Dtest=OrderPaymentIntegrationTest
```

### 3️⃣ Pruebas E2E

```bash
# Prerequisitos:
# 1. Todos los microservicios desplegados
# 2. API Gateway corriendo en puerto 8080

# Ejecutar todas las pruebas E2E
mvn verify -P e2e-tests

# Ejecutar pruebas específicas
mvn test -Dtest=CompleteUserJourneyE2ETest
mvn test -Dtest=ProductCatalogE2ETest
```

### 4️⃣ Pruebas de Rendimiento (Locust)

#### Instalación:
```bash
cd tests/performance
pip install -r requirements.txt
```

#### Ejecución:

**Modo Interfaz Web:**
```bash
locust -f locustfile.py
# Abrir: http://localhost:8089
```

**Prueba de Carga Normal:**
```bash
locust -f locustfile.py \
  --users 50 \
  --spawn-rate 5 \
  --run-time 5m \
  --html report.html
```

**Prueba de Estrés:**
```bash
locust -f locustfile.py \
  --users 200 \
  --spawn-rate 20 \
  --run-time 10m \
  --html stress-report.html
```

**Prueba de Picos (Spike Test):**
```bash
locust -f locustfile.py \
  --users 500 \
  --spawn-rate 100 \
  --run-time 2m \
  --html spike-report.html
```

**Prueba de Resistencia (Soak Test):**
```bash
locust -f locustfile.py \
  --users 100 \
  --spawn-rate 10 \
  --run-time 30m \
  --html soak-report.html
```

---

## 📊 Métricas y Reportes

### Cobertura de Código (JaCoCo)

```bash
# Generar reporte de cobertura
mvn clean test jacoco:report

# Ver reporte
# Abrir: target/site/jacoco/index.html
```

### Reportes de Locust

Los reportes HTML incluyen:
- ✅ Requests por segundo (RPS)
- ✅ Tiempo de respuesta (percentiles)
- ✅ Tasa de errores
- ✅ Distribución de usuarios
- ✅ Gráficos de rendimiento

---

## 🎯 Casos de Uso Cubiertos

### Flujo Completo de Usuario
1. Registro de usuario
2. Navegación de productos
3. Agregar a favoritos
4. Crear pedido
5. Procesar pago
6. Crear envío
7. Verificar historial

### Gestión de Productos
1. Listar catálogo
2. Buscar productos
3. Ver detalles
4. Actualizar información

### Procesamiento de Pedidos
1. Crear pedido
2. Validar usuario
3. Procesar pago
4. Generar envío
5. Manejar devoluciones

---

## 🔧 Configuración de Entorno de Pruebas

### application-test.yml

Crear en cada microservicio:

```yaml
spring:
  profiles: test
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  h2:
    console:
      enabled: true
  jpa:
    hibernate:
      ddl-auto: create-drop

eureka:
  client:
    enabled: false

management:
  endpoints:
    web:
      exposure:
        include: health,info
```

---

## 📈 Criterios de Aceptación

### Pruebas Unitarias
- ✅ Cobertura mínima: 80%
- ✅ Todas las pruebas deben pasar
- ✅ Sin warnings de compilación

### Pruebas de Integración
- ✅ Validar comunicación entre servicios
- ✅ Verificar integridad de datos
- ✅ Manejar errores correctamente

### Pruebas E2E
- ✅ Flujos completos funcionales
- ✅ Datos persistidos correctamente
- ✅ Respuestas en < 2 segundos

### Pruebas de Rendimiento
- ✅ RPS > 100 requests/segundo
- ✅ P95 < 500ms
- ✅ Tasa de error < 1%
- ✅ Sistema estable bajo carga

---

## 🐛 Troubleshooting

### Problema: Pruebas de integración fallan
**Solución**: Verificar que todos los servicios estén corriendo
```bash
kubectl get pods -n ecommerce-dev
```

### Problema: Locust no puede conectar
**Solución**: Verificar que API Gateway esté accesible
```bash
curl http://localhost:8080/actuator/health
```

### Problema: Pruebas E2E timeout
**Solución**: Aumentar timeout en configuración
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
@TestPropertySource(properties = {"spring.test.mockmvc.timeout=10000"})
```

---

## 📚 Dependencias Necesarias

### Maven (pom.xml)

```xml
<dependencies>
    <!-- Testing -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- REST Assured para pruebas de API -->
    <dependency>
        <groupId>io.rest-assured</groupId>
        <artifactId>rest-assured</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- AssertJ -->
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

---

## ✅ Checklist de Pruebas

- [x] 6+ Pruebas Unitarias (Service Layer)
- [x] 6+ Pruebas Unitarias (Controller Layer)
- [x] 6+ Pruebas de Integración
- [x] 11+ Pruebas E2E
- [x] Pruebas de Rendimiento con Locust
- [x] Documentación completa
- [x] Scripts de ejecución
- [x] Configuración de entorno de pruebas

---

**¡Suite completa de pruebas lista para el taller!** 🎉
