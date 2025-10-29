# Solución para el Error "kubectl: not found" en Jenkins

## Problema
El pipeline de Jenkins está fallando con el error:
```
kubectl: not found
```

Esto ocurre porque `kubectl` no está instalado en el agente de Jenkins.

## Solución

### Opción 1: Usar el Jenkinsfile Actualizado (Recomendado)
He actualizado el `Jenkinsfile` para instalar automáticamente todas las herramientas necesarias:

1. **kubectl** - Para interactuar con Kubernetes
2. **gcloud CLI** - Para autenticación con GCP
3. **Docker CLI** - Para construir imágenes
4. **Java 17 y Maven** - Para compilar los microservicios

El stage `Setup Build Tools` ahora instala automáticamente estas herramientas si no están presentes.

### Opción 2: Instalación Manual en el Agente Jenkins

Si prefieres instalar las herramientas manualmente en tu agente de Jenkins:

```bash
# Ejecutar en el agente de Jenkins
sudo ./scripts/setup-jenkins-tools.sh
```

### Opción 3: Usar Docker Agent (Alternativa)

Puedes modificar el Jenkinsfile para usar un agente Docker con todas las herramientas preinstaladas:

```groovy
pipeline {
    agent {
        docker {
            image 'google/cloud-sdk:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    // ... resto del pipeline
}
```

## Cambios Realizados en el Jenkinsfile

### 1. Variables de Entorno Mejoradas
- Agregado `USE_GKE_GCLOUD_AUTH_PLUGIN = 'True'`
- Mejorada la detección de branch y configuración de variables

### 2. Stage "Setup Build Tools" Mejorado
- Instalación automática de kubectl
- Instalación automática de gcloud CLI
- Verificación de todas las herramientas

### 3. Manejo de Variables Corregido
- Uso de variables globales para evitar problemas de scope
- Condiciones `when` mejoradas para mayor robustez

## Verificación

Para verificar que todo está funcionando correctamente, puedes ejecutar:

```bash
# Diagnóstico completo
./scripts/debug-pipeline.sh
```

Este script verificará:
- ✅ Herramientas instaladas
- ✅ Variables de entorno
- ✅ Conectividad de red
- ✅ Permisos
- ✅ Recursos del sistema

## Próximos Pasos

1. **Ejecuta el pipeline actualizado** - El nuevo Jenkinsfile debería resolver el problema automáticamente
2. **Verifica las credenciales de GCP** - Asegúrate de que las credenciales `gcp-service-account` y `gcp-project-id` estén configuradas en Jenkins
3. **Revisa los logs** - Si aún hay problemas, revisa los logs del stage "Setup Build Tools"

## Credenciales Necesarias en Jenkins

Asegúrate de tener configuradas estas credenciales en Jenkins:

- `gcp-service-account` (Secret file) - Archivo JSON de la cuenta de servicio de GCP
- `gcp-project-id` (Secret text) - ID del proyecto de GCP
- `dockerhub` (Username/Password) - Credenciales de Docker Hub (si usas Docker Hub)

## Troubleshooting Adicional

Si el problema persiste:

1. **Verifica el agente Jenkins** - Asegúrate de que el agente tenga permisos de sudo
2. **Revisa la conectividad** - El agente debe poder acceder a Internet
3. **Verifica el espacio en disco** - Asegúrate de tener suficiente espacio
4. **Revisa los logs completos** - Busca errores específicos en los logs del pipeline

## Contacto

Si necesitas ayuda adicional, revisa los logs del pipeline y proporciona:
- Logs completos del stage que falla
- Información del agente Jenkins (OS, versión)
- Configuración de credenciales