# Configuración de Reportes en Jenkins

## Reportes Implementados

Los pipelines de Jenkins ahora generan los siguientes reportes:

### 1. Reportes de Pruebas Unitarias (JUnit)
- **Ubicación**: Ya configurado en todos los Jenkinsfiles
- **Formato**: XML (JUnit)
- **Visualización**: Jenkins Test Results
- **Acceso**: En cada build → "Test Result"

### 2. Reporte de Cobertura de Código (JaCoCo)
- **Plugin necesario**: JaCoCo Maven Plugin
- **Ubicación**: `target/site/jacoco/index.html`
- **Métricas**: 
  - Cobertura de líneas
  - Cobertura de ramas
  - Cobertura de métodos
  - Cobertura de clases

### 3. Reporte HTML de Build
- **Contenido**:
  - Información del build (número, fecha, servicio)
  - Estado de cada stage del pipeline
  - Artefactos generados
  - Links a reportes detallados
- **Visualización**: Jenkins HTML Publisher Plugin

## Configuración de JaCoCo

### Agregar JaCoCo a pom.xml

Para cada microservicio, agregar el siguiente plugin en la sección `<build><plugins>`:

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.8</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Servicios Configurados

- ✅ user-service
- ⏳ product-service (pendiente)
- ⏳ order-service (pendiente)
- ⏳ payment-service (pendiente)
- ⏳ shipping-service (pendiente)
- ⏳ favourite-service (pendiente)

## Plugins de Jenkins Necesarios

Para visualizar todos los reportes correctamente, instala estos plugins en Jenkins:

1. **JUnit Plugin** (ya instalado por defecto)
2. **JaCoCo Plugin**
   ```bash
   docker exec jenkins jenkins-plugin-cli --plugins jacoco
   ```

3. **HTML Publisher Plugin**
   ```bash
   docker exec jenkins jenkins-plugin-cli --plugins htmlpublisher
   ```

## Acceder a los Reportes

### Desde la Interfaz de Jenkins

1. **Test Results**:
   - Build → Test Result
   - Muestra pruebas pasadas/fallidas
   - Detalles de cada test

2. **Code Coverage**:
   - Build → JaCoCo Coverage Report
   - Gráficos de cobertura
   - Detalles por paquete/clase

3. **Build Report**:
   - Build → Build Report
   - Resumen HTML del build
   - Estado de stages

### Desde el Workspace

Los reportes también están disponibles en:
- `target/surefire-reports/` - Reportes de tests
- `target/site/jacoco/` - Reportes de cobertura
- `reports/` - Reportes HTML personalizados

## Métricas Recolectadas

### Por Build
- Número de tests ejecutados
- Tests pasados/fallidos
- Tiempo de ejecución
- Cobertura de código (%)
- Artefactos generados

### Por Servicio
- Historial de cobertura
- Tendencia de tests
- Tiempo de build
- Tasa de éxito

## Ejemplo de Uso

Después de ejecutar un pipeline:

1. Ve al build en Jenkins
2. Haz clic en "Test Result" para ver las pruebas
3. Haz clic en "JaCoCo Coverage Report" para ver la cobertura
4. Haz clic en "Build Report" para ver el resumen HTML

## Próximos Pasos

1. Instalar plugins de Jenkins necesarios
2. Agregar JaCoCo a los pom.xml restantes
3. Ejecutar pipelines para generar reportes
4. Revisar y ajustar umbrales de cobertura

## Comandos Útiles

### Generar reporte de cobertura localmente
```bash
cd user-service
mvn clean test jacoco:report
# Ver reporte en: target/site/jacoco/index.html
```

### Instalar plugins de Jenkins
```bash
docker exec jenkins jenkins-plugin-cli --plugins jacoco htmlpublisher
docker restart jenkins
```

### Ver logs de Jenkins
```bash
docker logs jenkins -f
```
