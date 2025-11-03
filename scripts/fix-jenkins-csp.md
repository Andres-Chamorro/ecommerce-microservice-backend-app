# Solución: Jenkins Content Security Policy

## Problema
Jenkins bloquea JavaScript en artifacts por seguridad (CSP - Content Security Policy).

## Solución Rápida: Descargar el Archivo

1. Click derecho en `locust-report.html` → "Save link as..."
2. Guardar en tu PC
3. Abrir con navegador (Chrome/Firefox)
4. ✅ Funciona perfectamente

---

## Solución Permanente: Configurar Jenkins

### Opción A: Desde la UI de Jenkins

1. **Ir a Manage Jenkins**
   ```
   Jenkins → Manage Jenkins → Script Console
   ```

2. **Ejecutar este script:**
   ```groovy
   System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")
   ```

3. **Reiniciar Jenkins**
   ```bash
   # En tu terminal
   docker restart jenkins
   ```

### Opción B: Variable de Entorno (Recomendado)

Agregar al `docker-compose.yml` o comando de inicio de Jenkins:

```yaml
environment:
  - JAVA_OPTS=-Dhudson.model.DirectoryBrowserSupport.CSP=""
```

O al iniciar Jenkins:

```bash
docker run -d \
  -p 8079:8080 \
  -e JAVA_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP=''" \
  jenkins/jenkins:lts
```

### Opción C: Configuración Menos Restrictiva (Más Seguro)

Si no quieres deshabilitar completamente CSP:

```groovy
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", 
  "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';")
```

---

## ⚠️ Nota de Seguridad

Deshabilitar CSP completamente puede ser un riesgo de seguridad en producción.

**Para desarrollo/informe**: Está bien deshabilitarlo temporalmente.

**Para producción**: Mejor usar HTML Publisher Plugin que maneja CSP correctamente.

---

## 🎯 Recomendación para tu Informe

**Opción más simple:**
1. Descargar `locust-report.html`
2. Abrirlo localmente
3. Tomar screenshots para el informe
4. ✅ Listo

**No necesitas configurar nada en Jenkins** para tu informe.
