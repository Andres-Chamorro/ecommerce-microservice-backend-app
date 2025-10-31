# Solución: gcloud not found en Jenkins

## Problema
```
gcloud: not found
script returned exit code 127
```

## Causa
El pipeline `product-service-pipeline_dev` está usando el Jenkinsfile incorrecto:
- **Usando**: `product-service/Jenkinsfile` (configurado para GCP)
- **Debería usar**: `product-service/Jenkinsfile.dev` (configurado para Minikube)

## Solución

### Opción 1: Configurar Jenkins manualmente (RECOMENDADO)

Para cada servicio, configura el pipeline según la rama:

#### Para pipelines DEV:
1. Ve a Jenkins → `[servicio]-pipeline_dev` → Configure
2. En la sección "Pipeline":
   - Script Path: `[servicio]/Jenkinsfile.dev`
3. Guarda los cambios

#### Para pipelines STAGING:
1. Ve a Jenkins → `[servicio]-pipeline_staging` → Configure
2. En la sección "Pipeline":
   - Script Path: `[servicio]/Jenkinsfile.staging`
3. Guarda los cambios

#### Para pipelines MASTER/PROD:
1. Ve a Jenkins → `[servicio]-pipeline_master` → Configure
2. En la sección "Pipeline":
   - Script Path: `[servicio]/Jenkinsfile.master`
3. Guarda los cambios

### Opción 2: Instalar gcloud en Jenkins (NO RECOMENDADO para DEV)

Si realmente quieres usar GCP para el ambiente DEV:

```powershell
# Instalar Google Cloud SDK en Jenkins
.\scripts\install-gcloud-jenkins.ps1

# Configurar credenciales
docker cp tu-archivo-credenciales.json jenkins:/tmp/gcp-key.json
docker exec jenkins gcloud auth activate-service-account --key-file=/tmp/gcp-key.json
docker exec jenkins gcloud config set project tu-proyecto-id
```

## Arquitectura de Jenkinsfiles

```
Servicio/
├── Jenkinsfile           → GCP (por defecto, para master)
├── Jenkinsfile.dev       → Minikube (local)
├── Jenkinsfile.staging   → GCP Staging
└── Jenkinsfile.master    → GCP Production
```

## Verificación

Después de configurar, verifica que el pipeline use el Jenkinsfile correcto:

1. Ejecuta el pipeline
2. En la consola de Jenkins, deberías ver:
   - Para DEV: `[DEV] Construyendo imagen Docker...` y uso de Minikube
   - Para STAGING: `[STAGING] Construyendo imagen Docker...` y push a GCP
   - Para MASTER: `[PROD] Construyendo imagen Docker...` y push a GCP

## Servicios afectados

Todos los servicios tienen esta estructura:
- user-service
- product-service
- order-service
- payment-service
- shipping-service
- favourite-service

## Próximos pasos

1. Configura todos los pipelines DEV para usar `Jenkinsfile.dev`
2. Configura todos los pipelines STAGING para usar `Jenkinsfile.staging`
3. Configura todos los pipelines MASTER para usar `Jenkinsfile.master`
4. Ejecuta un pipeline de prueba para cada ambiente
