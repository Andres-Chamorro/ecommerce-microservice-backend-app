# Release Notes - Ambiente de Desarrollo (Dev)

## Información del Ambiente
- **Ambiente**: Desarrollo (Dev)
- **Rama Git**: `dev`
- **Infraestructura**: Minikube (Local)
- **Namespace Kubernetes**: `ecommerce-dev`
- **Propósito**: Desarrollo activo y pruebas de integración

## Versiones Actuales Desplegadas

### Microservicios

| Servicio | Versión | Fecha Despliegue | Build | Imagen Docker |
|----------|---------|------------------|-------|---------------|
| user-service | dev-latest | 2025-11-03 | #${BUILD_NUMBER} | user-service:dev-${BUILD_NUMBER} |
| product-service | dev-latest | 2025-11-03 | #${BUILD_NUMBER} | product-service:dev-${BUILD_NUMBER} |
| order-service | dev-latest | 2025-11-03 | #${BUILD_NUMBER} | order-service:dev-${BUILD_NUMBER} |
| payment-service | dev-latest | 2025-11-03 | #${BUILD_NUMBER} | payment-service:dev-${BUILD_NUMBER} |
| favourite-service | dev-latest | 2025-11-03 | #${BUILD_NUMBER} | favourite-service:dev-${BUILD_NUMBER} |
| shipping-service | dev-latest | 2025-11-03 | #${BUILD_NUMBER} | shipping-service:dev-${BUILD_NUMBER} |

## Características del Ambiente Dev

### Configuración
- **Base de Datos**: PostgreSQL en contenedor
- **Registro de Imágenes**: Local (Minikube)
- **Réplicas**: 1 por servicio
- **Recursos**: Limitados (desarrollo local)

### Pruebas Ejecutadas
- ✅ Pruebas unitarias
- ✅ Pruebas de integración
- ⚠️ Pruebas E2E (opcional)
- ⚠️ Pruebas de rendimiento (opcional)

### Acceso a Servicios
Los servicios están disponibles a través de Minikube:
```bash
minikube service <service-name> -n ecommerce-dev
```

## Historial de Cambios

### 2025-11-03
- ✅ Configuración inicial del ambiente de desarrollo
- ✅ Implementación de pruebas de integración con URLs configurables
- ✅ Corrección de Jenkinsfiles (eliminación de BOM)
- ✅ Integración con Minikube local

### Próximos Pasos
- Ejecutar pipeline completo en dev
- Validar pruebas de integración
- Preparar merge a staging

## Notas Técnicas

### Cómo Desplegar
```bash
# Desde Jenkins
# Ejecutar pipeline de la rama 'dev' para cualquier servicio
```

### Cómo Verificar Despliegue
```bash
kubectl get pods -n ecommerce-dev
kubectl get services -n ecommerce-dev
```

### Rollback
```bash
kubectl rollout undo deployment/<service-name> -n ecommerce-dev
```

## Contacto
- **Equipo**: Desarrollo
- **Pipeline**: Jenkins (rama dev)
- **Documentación**: Ver README.md del proyecto

---
**Última actualización**: 2025-11-03  
**Actualizado por**: Pipeline automatizado
