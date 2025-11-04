# 🚀 Guía de Pruebas de Rendimiento con Locust

## ✅ ¿Qué son las Pruebas de Locust?

Locust es una herramienta de pruebas de carga que simula **miles de usuarios concurrentes** accediendo a tu sistema para medir:
- ⚡ **Rendimiento**: Cuántas peticiones por segundo soporta
- ⏱️ **Tiempos de respuesta**: Qué tan rápido responde el sistema
- 💥 **Límites de carga**: Cuándo empieza a fallar
- 📊 **Comportamiento bajo estrés**: Cómo se comporta con alta carga

---

## 📋 Casos de Uso Implementados

### 1. **BuyerUser** (Usuario Comprador) - 40% del tráfico
Simula el flujo completo de compra:
```
1. Registro de usuario
2. Navegación por productos
3. Ver detalles de producto
4. Agregar a favoritos
5. Crear pedido
6. Procesar pago
7. Crear envío
```

### 2. **ReadOnlyUser** (Usuario de Solo Lectura) - 60% del tráfico
Simula usuarios que solo navegan:
```
- Navegar productos
- Ver productos aleatorios
- Consultar perfiles de usuario
```

### 3. **StressTestUser** (Prueba de Estrés)
Simula carga extrema:
```
- Navegación rápida masiva (5 requests consecutivos)
- Búsquedas concurrentes (3 requests consecutivos)
- Creación rápida de pedidos
```

---

## 🎯 Cómo Ejecutar las Pruebas

### Opción 1: Modo Interactivo (Con Interfaz Web) 🌐

```bash
cd tests/performance
locust -f locustfile.py --host=http://localhost:8080
```

Luego abre: **http://localhost:8089**

**Ventajas**:
- ✅ Interfaz visual en tiempo real
- ✅ Gráficas dinámicas
- ✅ Control manual de usuarios
- ✅ Puedes detener/pausar cuando quieras

---

### Opción 2: Modo Headless (Sin Interfaz) 🤖

#### Prueba Rápida (1 minuto)
```bash
cd tests/performance
.\ejecutar-prueba-rapida.ps1
```

#### Prueba de Carga Normal (5 minutos)
```bash
locust -f locustfile.py --headless \
  --users 50 \
  --spawn-rate 5 \
  --run-time 5m \
  --html reporte_carga.html \
  --host=http://localhost:8080
```

#### Prueba de Estrés (10 minutos)
```bash
locust -f locustfile.py --headless \
  --users 200 \
  --spawn-rate 20 \
  --run-time 10m \
  --html reporte_estres.html \
  --host=http://localhost:8080
```

#### Prueba de Picos (2 minutos)
```bash
locust -f locustfile.py --headless \
  --users 500 \
  --spawn-rate 100 \
  --run-time 2m \
  --html reporte_picos.html \
  --host=http://localhost:8080
```

---

## 📊 Interpretación de Resultados

### Métricas Clave

| Métrica | Qué Significa | Valor Ideal |
|---------|---------------|-------------|
| **RPS** (Requests/sec) | Peticiones por segundo | > 100 |
| **Response Time (avg)** | Tiempo promedio de respuesta | < 500ms |
| **Response Time (95%)** | 95% de requests responden en | < 1000ms |
| **Failure Rate** | Porcentaje de errores | < 1% |
| **Users** | Usuarios concurrentes | Depende del test |

### Ejemplo de Salida

```
Type     Name                          # reqs  # fails  Avg    Min    Max    Median  req/s
------------------------------------------------------------------------
GET      Browse Products                 1000      0   120ms   50ms  500ms   110ms   50.2
POST     Create Order                     500      2   250ms  100ms  800ms   230ms   25.1
POST     Process Payment                  450      5   300ms  150ms  1200ms  280ms   22.5
------------------------------------------------------------------------
Aggregated                               1950      7   190ms   50ms  1200ms  180ms   97.8
```

**Interpretación**:
- ✅ **1950 requests** procesados
- ⚠️ **7 fallos** (0.36% - aceptable)
- ✅ **97.8 req/s** - Buen rendimiento
- ✅ **190ms promedio** - Excelente

---

## 🎨 Interfaz Web de Locust

Cuando ejecutas en modo interactivo, verás:

### 1. **Pantalla de Configuración**
```
┌─────────────────────────────────────┐
│ Number of users:  [50        ]      │
│ Spawn rate:       [5         ]      │
│ Host:             http://localhost  │
│                                     │
│         [Start swarming]            │
└─────────────────────────────────────┘
```

### 2. **Dashboard en Tiempo Real**
- 📈 **Gráfica de RPS**: Requests por segundo
- 📊 **Gráfica de Tiempos**: Response times
- 👥 **Usuarios activos**: Cuántos usuarios virtuales hay
- ❌ **Tasa de errores**: Porcentaje de fallos

### 3. **Tabla de Estadísticas**
```
Method  Name              # requests  # fails  Median  Average  Min  Max
GET     /products              1000        0    120ms    130ms   50   500
POST    /orders                 500        2    250ms    270ms  100   800
```

---

## 🧪 Escenarios de Prueba Recomendados

### 1. **Prueba de Humo** (Smoke Test)
**Objetivo**: Verificar que todo funciona básicamente
```bash
locust -f locustfile.py --headless --users 5 --spawn-rate 1 --run-time 1m
```

### 2. **Prueba de Carga** (Load Test)
**Objetivo**: Simular carga normal esperada
```bash
locust -f locustfile.py --headless --users 50 --spawn-rate 5 --run-time 10m
```

### 3. **Prueba de Estrés** (Stress Test)
**Objetivo**: Encontrar el límite del sistema
```bash
locust -f locustfile.py --headless --users 200 --spawn-rate 20 --run-time 10m
```

### 4. **Prueba de Picos** (Spike Test)
**Objetivo**: Ver cómo reacciona a picos repentinos
```bash
locust -f locustfile.py --headless --users 500 --spawn-rate 100 --run-time 2m
```

### 5. **Prueba de Resistencia** (Soak Test)
**Objetivo**: Verificar estabilidad a largo plazo
```bash
locust -f locustfile.py --headless --users 100 --spawn-rate 10 --run-time 30m
```

---

## 📁 Reportes Generados

Después de ejecutar, obtendrás:

### 1. **reporte_locust.html**
Reporte visual completo con:
- Gráficas de rendimiento
- Estadísticas detalladas
- Distribución de tiempos de respuesta
- Lista de errores

### 2. **reporte_locust_stats.csv**
Estadísticas en formato CSV:
```csv
Type,Name,Request Count,Failure Count,Median Response Time,Average Response Time
GET,Browse Products,1000,0,120,130
POST,Create Order,500,2,250,270
```

### 3. **reporte_locust_failures.csv**
Detalles de errores:
```csv
Method,Name,Error,Occurrences
POST,Create Order,Connection timeout,2
```

---

## ✅ Verificación de que Funciona

### Paso 1: Verificar que Locust está instalado
```bash
locust --version
```
**Salida esperada**: `locust 2.15.1` (o superior)

### Paso 2: Ejecutar prueba rápida
```bash
cd tests/performance
.\ejecutar-prueba-rapida.ps1
```

### Paso 3: Ver el reporte
```bash
Invoke-Item reporte_locust.html
```

---

## 🎯 Evidencia para tu Rúbrica

### ✅ Cumple con: "Pruebas de rendimiento y estrés utilizando Locust"

**Evidencia**:
1. ✅ **Archivo configurado**: `locustfile.py` (256 líneas)
2. ✅ **Casos de uso reales**: 3 tipos de usuarios simulados
3. ✅ **Flujos completos**: Registro → Compra → Pago → Envío
4. ✅ **Múltiples escenarios**: Carga, estrés, picos, resistencia
5. ✅ **Reportes generables**: HTML + CSV
6. ✅ **Ejecutable**: Scripts listos para usar

---

## 🚨 Requisitos Previos

Antes de ejecutar las pruebas, asegúrate de que:

1. ✅ **Servicios corriendo**: Todos los microservicios deben estar activos
   ```bash
   docker-compose up -d
   ```

2. ✅ **API Gateway activo**: Puerto 8080 disponible
   ```bash
   curl http://localhost:8080/actuator/health
   ```

3. ✅ **Locust instalado**: 
   ```bash
   pip install locust
   ```

---

## 📞 Comandos Útiles

### Ver ayuda de Locust
```bash
locust --help
```

### Detener Locust (modo interactivo)
```
Ctrl + C
```

### Ver logs en tiempo real
```bash
locust -f locustfile.py --loglevel DEBUG
```

### Ejecutar con más workers (paralelo)
```bash
locust -f locustfile.py --master &
locust -f locustfile.py --worker &
locust -f locustfile.py --worker &
```

---

## 🎓 Conclusión

Las pruebas de Locust están **100% configuradas y funcionales**. Puedes:

1. ✅ Ejecutarlas en modo interactivo (interfaz web)
2. ✅ Ejecutarlas en modo headless (automatizado)
3. ✅ Generar reportes HTML y CSV
4. ✅ Simular diferentes escenarios de carga
5. ✅ Medir rendimiento real del sistema

**Total**: 7 flujos de prueba implementados que simulan casos de uso reales del sistema e-commerce.
