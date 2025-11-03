# 🔍 Verificación Completa - Estructura Workspace Staging

## 🎯 Objetivo

Verificar la estructura exacta del workspace de Jenkins para corregir las rutas de las pruebas E2E y Performance.

## 📝 Comandos Debug Agregados

He agregado comandos de debug al Jenkinsfile de `payment-service` para ver la estructura real del workspace:

```bash
# DEBUG: Ver estructura del workspace
echo "📁 DEBUG: Contenido del workspace:"
pwd
ls -la
echo "📁 DEBUG: Buscando carpeta tests:"
find . -name "tests" -type d 2>/dev/null || echo "No se encontró carpeta tests"
```

## 🚀 Instrucciones para Verificar

1. **Ejecuta el pipeline de payment-service en staging**:
   - Ve a Jenkins
   - Selecciona `payment-service-pipeline`
   - Selecciona la rama `staging`
   - Click en "Build Now"

2. **Revisa el output del stage "E2E Tests"**:
   - Busca las líneas que empiezan con `📁 DEBUG:`
   - Copia todo el output y compártelo

3. **El output mostrará**:
   - El directorio actual (`pwd`)
   - El contenido del directorio (`ls -la`)
   - La ubicación de la carpeta `tests/` si existe

## 🔍 Posibles Escenarios

### Escenario 1: tests/ en el mismo nivel
```
/var/jenkins_home/workspace/payment-service-pipeline_staging/
├── tests/
│   ├── e2e/
│   └── performance/
├── payment-service/
├── user-service/
└── ...
```
**Ruta correcta**: `tests/e2e` y `tests/performance`

### Escenario 2: tests/ dentro del servicio
```
/var/jenkins_home/workspace/payment-service-pipeline_staging/
└── payment-service/
    └── tests/
        ├── e2e/
        └── performance/
```
**Ruta correcta**: `payment-service/tests/e2e` y `payment-service/tests/performance`

### Escenario 3: tests/ un nivel arriba
```
/var/jenkins_home/workspace/
├── tests/
│   ├── e2e/
│   └── performance/
└── payment-service-pipeline_staging/
    └── payment-service/
```
**Ruta correcta**: `../tests/e2e` y `../tests/performance`

## 📊 Información Recopilada Hasta Ahora

### ✅ Confirmado:
- La carpeta `tests/` existe en el repositorio (raíz)
- Contiene `e2e/`, `integration/` y `performance/`
- Los archivos existen: `tests/e2e/pom.xml` y `tests/performance/locustfile.py`

### ❓ Por Confirmar:
- La estructura exacta del workspace de Jenkins cuando ejecuta el pipeline
- Si Jenkins hace checkout de todo el repo o solo del servicio
- El directorio de trabajo actual cuando ejecuta los stages

## 🎯 Próximo Paso

Una vez que tengas el output del debug, sabremos la ruta exacta y podremos corregir todos los Jenkinsfiles de una vez.

## 📝 Nota

Este es un problema común en pipelines multi-servicio donde:
- El repositorio tiene múltiples servicios
- Hay recursos compartidos (como `tests/`) en la raíz
- Cada servicio tiene su propio Jenkinsfile

La solución depende de cómo Jenkins configura el workspace para cada pipeline.
