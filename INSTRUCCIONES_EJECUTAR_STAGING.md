# 📋 Instrucciones: Ejecutar Pipeline Staging con Debug

## 🎯 Objetivo

Ejecutar el pipeline de `payment-service` en staging para ver la estructura del workspace y corregir las rutas de pruebas.

## 🚀 Pasos a Seguir

### 1. Hacer Push de los Cambios

```powershell
git push origin staging
```

### 2. Ir a Jenkins

1. Abre tu navegador
2. Ve a `http://localhost:8080`
3. Busca el pipeline `payment-service-pipeline`

### 3. Ejecutar el Pipeline en Staging

1. Click en `payment-service-pipeline`
2. En el menú izquierdo, click en "Scan Multibranch Pipeline Now" (o espera a que se detecte automáticamente)
3. Selecciona la rama `staging`
4. Click en "Build Now"

### 4. Ver el Output del Stage E2E Tests

1. Click en el número del build (ej: #10)
2. Click en "Console Output"
3. Busca la sección del stage "E2E Tests"
4. Copia TODO el output que empieza con:
   ```
   📁 DEBUG: Contenido del workspace:
   ```

### 5. Compartir el Output

Copia y pega el output completo del debug, especialmente estas líneas:

```bash
📁 DEBUG: Contenido del workspace:
/var/jenkins_home/workspace/...
total XX
drwxr-xr-x ...
...

📁 DEBUG: Buscando carpeta tests:
./tests
```

## 🔍 Qué Buscar en el Output

### Información Clave:

1. **Directorio actual** (`pwd`):
   - ¿Dónde está parado Jenkins cuando ejecuta el script?
   - Ejemplo: `/var/jenkins_home/workspace/payment-service-pipeline_staging`

2. **Contenido del directorio** (`ls -la`):
   - ¿Qué archivos y carpetas hay?
   - ¿Está la carpeta `tests/`?
   - ¿Están las carpetas de servicios (`payment-service/`, `user-service/`, etc.)?

3. **Ubicación de tests** (`find . -name "tests"`):
   - ¿Dónde está la carpeta `tests/`?
   - Ejemplo: `./tests` o `./payment-service/tests` o no se encuentra

## 📊 Ejemplo de Output Esperado

```bash
+ echo 📁 DEBUG: Contenido del workspace:
📁 DEBUG: Contenido del workspace:
+ pwd
/var/jenkins_home/workspace/payment-service-pipeline_staging
+ ls -la
total 120
drwxr-xr-x 15 root root  4096 Nov  2 02:30 .
drwxr-xr-x 50 root root  4096 Nov  2 02:30 ..
drwxr-xr-x  8 root root  4096 Nov  2 02:30 .git
-rw-r--r--  1 root root  1234 Nov  2 02:30 .gitignore
drwxr-xr-x  3 root root  4096 Nov  2 02:30 favourite-service
drwxr-xr-x  3 root root  4096 Nov  2 02:30 order-service
drwxr-xr-x  3 root root  4096 Nov  2 02:30 payment-service
drwxr-xr-x  3 root root  4096 Nov  2 02:30 product-service
drwxr-xr-x  3 root root  4096 Nov  2 02:30 shipping-service
drwxr-xr-x  5 root root  4096 Nov  2 02:30 tests          ← AQUÍ ESTÁ
drwxr-xr-x  3 root root  4096 Nov  2 02:30 user-service
+ echo 📁 DEBUG: Buscando carpeta tests:
📁 DEBUG: Buscando carpeta tests:
+ find . -name tests -type d
./tests                                                    ← CONFIRMADO
```

## ✅ Con Esta Información

Una vez que tengamos el output, sabremos:
- ✅ La ruta exacta para acceder a `tests/e2e`
- ✅ La ruta exacta para acceder a `tests/performance`
- ✅ Podremos corregir todos los Jenkinsfiles correctamente

## 🎯 Resultado Esperado

Después de la corrección, verás:

```bash
+ [ -d tests/e2e ]
+ echo Ejecutando pruebas E2E...
Ejecutando pruebas E2E...
+ cd tests/e2e
+ mvn test -Dtest=*E2ETest -Dservice.url=http://104.198.32.214:8400
[INFO] Scanning for projects...
[INFO] Building E2E Tests 1.0.0
[INFO] Running tests...
```

En lugar de:

```bash
+ [ -d tests/e2e ]
+ echo No hay pruebas E2E configuradas
No hay pruebas E2E configuradas
```
