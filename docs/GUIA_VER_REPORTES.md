# 📊 Guía para Ver Reportes de Pruebas

## 🎯 Reportes Disponibles

Cada pipeline de staging genera 2 tipos de reportes:

1. **Reportes E2E** (XML) - Pruebas funcionales
2. **Reportes de Performance** (HTML) - Pruebas de carga con Locust

---

## 📁 Cómo Acceder a los Reportes en Jenkins

### Método 1: Desde la Interfaz de Jenkins

1. **Ir al Job del servicio**
   ```
   Jenkins → [nombre-del-servicio] (ej: order-service)
   ```

2. **Seleccionar el build**
   ```
   Click en el número de build (ej: #15)
   ```

3. **Ver Archived Artifacts**
   ```
   Scroll down → "Build Artifacts" o "Archived Artifacts"
   ```

4. **Descargar/Ver reportes**
   - **E2E**: `tests/e2e/target/surefire-reports/*.xml`
   - **Performance**: `tests/performance/locust-report.html` ← Click para ver en navegador

---

## 🌐 Ver Reportes HTML de Locust

Los reportes de Locust ya están en formato HTML bonito con gráficos.

**Pasos:**
1. Jenkins → Job → Build #X
2. Click en `locust-report.html` en "Archived Artifacts"
3. Se abre automáticamente en el navegador

**Contenido del reporte:**
- 📊 Gráficos de requests por segundo
- ⏱️ Tiempos de respuesta (percentiles)
- ❌ Tasa de fallos
- 📈 Distribución de carga
- 📋 Tabla detallada por endpoint

---

## 📄 Ver Reportes XML de E2E

Los reportes XML son menos visuales, pero contienen toda la información.

### Opción A: Ver en Jenkins con Plugin (Recomendado)

**1. Instalar HTML Publisher Plugin**
```
Jenkins → Manage Jenkins → Manage Plugins → Available
Buscar: "HTML Publisher Plugin"
Instalar y reiniciar
```

**2. Los reportes se verán automáticamente en Jenkins**
- Aparecerá un link "Test Results" en cada build
- Click para ver resumen visual

### Opción B: Descargar y Ver Localmente

**1. Descargar los XML**
```
Jenkins → Build → Archived Artifacts → Download
```

**2. Ver en navegador**
- Los archivos XML se pueden abrir en cualquier navegador
- O usar herramientas como:
  - **VS Code** con extensión "XML Tools"
  - **Online XML Viewer**: https://codebeautify.org/xmlviewer

### Opción C: Convertir a HTML (Manual)

**Usar el script incluido:**
```bash
cd tests/e2e/target/surefire-reports
bash ../../../../scripts/generate-test-report-html.sh
# Genera: test-report.html
```

---

## 🖼️ Extensiones Recomendadas para VS Code

Si quieres ver los reportes directamente en VS Code:

### 1. Para XML (Reportes E2E)
```
Extensión: "XML Tools" por Josh Johnson
- Syntax highlighting
- Formatting
- XPath evaluation
```

### 2. Para HTML (Reportes Locust)
```
Extensión: "Live Server" por Ritwick Dey
- Click derecho en .html → "Open with Live Server"
- Se abre en navegador con auto-refresh
```

### 3. Para Visualización General
```
Extensión: "Preview" por Thomas Haakon Townsend
- Previsualiza HTML/XML directamente en VS Code
- Ctrl+Shift+V para preview
```

---

## 📊 Interpretar los Reportes

### Reporte E2E (XML)

**Estructura típica:**
```xml
<testsuite name="CompleteUserJourneyE2ETest" 
           tests="14" 
           failures="0" 
           errors="0" 
           skipped="0" 
           time="2.345">
  <testcase name="testUserRegistration" time="0.234"/>
  <testcase name="testCreateOrder" time="0.456"/>
  ...
</testsuite>
```

**Qué buscar:**
- ✅ `failures="0"` y `errors="0"` = Todo bien
- ❌ `failures > 0` = Pruebas fallidas (revisar)
- ⏱️ `time` = Duración de las pruebas

### Reporte de Performance (HTML)

**Métricas clave:**

1. **Requests per second (RPS)**
   - Cuántas requests maneja el servicio por segundo
   - Más alto = mejor rendimiento

2. **Response Time Percentiles**
   - **50% (Median)**: Tiempo típico
   - **95%**: El 95% de requests son más rápidas que esto
   - **99%**: Casos extremos
   - Más bajo = mejor

3. **Failure Rate**
   - Porcentaje de requests fallidas
   - **0%** = Perfecto ✅
   - **< 1%** = Aceptable
   - **> 5%** = Problema ❌

4. **Total Requests**
   - Cantidad total de requests ejecutadas
   - Valida que la prueba corrió completamente

---

## 🎨 Ejemplo de Reporte Locust

```
┌─────────────────────────────────────────────────┐
│  📊 Performance Test Results                    │
├─────────────────────────────────────────────────┤
│  Total Requests:     6,600                      │
│  Failures:           0 (0%)                     │
│  Avg Response Time:  7ms                        │
│  95th Percentile:    19ms                       │
│  Requests/sec:       32.8                       │
│  Test Duration:      2m 0s                      │
└─────────────────────────────────────────────────┘

Type     Name                    # reqs  # fails  Avg   95%
---------|----------------------|--------|--------|------|-----
GET      GET Health Check         500      0      5ms   11ms
GET      GET Browse Resources    1000      0      8ms   21ms
POST     POST Create Resource     600      0     12ms   28ms
...
```

---

## 💡 Tips para tu Informe

### Screenshots Recomendados

1. **Dashboard de Jenkins**
   - Muestra todos los builds exitosos (verde)

2. **Reporte de Locust**
   - Gráfico de RPS over time
   - Tabla de response times
   - Sección de "0% failures"

3. **Logs de Jenkins**
   - Stage "E2E Tests" exitoso
   - Stage "Performance Tests" exitoso

### Datos para Incluir

```markdown
## Resultados de Pruebas

### Pruebas E2E
- Total de pruebas: 23
- Exitosas: 23 (100%)
- Fallidas: 0
- Tiempo de ejecución: ~2-3 minutos

### Pruebas de Performance
- Usuarios concurrentes: 50
- Duración: 2 minutos
- Total de requests: 6,600
- Tasa de fallos: 0%
- Tiempo de respuesta promedio: 7ms
- Percentil 95: 19ms
- Requests por segundo: 32.8
```

---

## 🔧 Troubleshooting

### No veo los reportes en Jenkins

**Problema**: "No archived artifacts"

**Solución**:
1. Verificar que el pipeline terminó exitosamente
2. Revisar logs del stage "E2E Tests" o "Performance Tests"
3. Verificar que exista el directorio `tests/e2e` o `tests/performance`

### Los XML no se ven bien

**Solución**:
- Usar extensión de VS Code "XML Tools"
- O convertir a HTML con el script incluido
- O instalar HTML Publisher Plugin en Jenkins

### El HTML de Locust no carga

**Solución**:
- Descargar el archivo localmente
- Abrir con navegador (Chrome/Firefox)
- O usar "Live Server" en VS Code

---

## 📞 Comandos Útiles

### Descargar reportes desde Jenkins (CLI)

```bash
# Descargar reporte de Locust
wget http://jenkins-url/job/SERVICE_NAME/BUILD_NUMBER/artifact/tests/performance/locust-report.html

# Descargar reportes E2E
wget -r -np -nH --cut-dirs=5 http://jenkins-url/job/SERVICE_NAME/BUILD_NUMBER/artifact/tests/e2e/target/surefire-reports/
```

### Ver reportes localmente

```bash
# Abrir reporte de Locust en navegador
start tests/performance/locust-report.html  # Windows
open tests/performance/locust-report.html   # Mac
xdg-open tests/performance/locust-report.html  # Linux

# Generar HTML desde XML
bash scripts/generate-test-report-html.sh
start test-report.html
```

---

## ✅ Checklist para el Informe

- [ ] Screenshot del dashboard de Jenkins (todos los builds verdes)
- [ ] Screenshot del reporte de Locust (gráficos y métricas)
- [ ] Tabla con resultados de E2E tests
- [ ] Tabla con métricas de performance
- [ ] Explicación de la estrategia de testing (port-forward)
- [ ] Conclusiones sobre la calidad del sistema

---

**¿Necesitas ayuda?**
- Los reportes están en: `Jenkins → Job → Build → Archived Artifacts`
- Para visualización avanzada: Instalar "HTML Publisher Plugin"
- Para tu informe: Usa screenshots del reporte HTML de Locust (se ve profesional)
