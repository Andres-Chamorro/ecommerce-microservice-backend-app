# Instrucciones para Ejecutar Pipeline en Jenkins

## Estado Actual
✅ Kubeconfig configurado correctamente (solo Minikube)
✅ Certificados de Minikube copiados a Jenkins
✅ Jenkinsfiles actualizados con estrategia docker save/load
✅ imagePullPolicy configurado a Never
✅ Todos los deployments antiguos eliminados
✅ Cambios commiteados y pusheados a rama dev

## Estrategia de Build Implementada

Los Jenkinsfiles ahora usan la siguiente estrategia para construir y cargar imágenes en Minikube:

1. **Construir imagen con Docker** en Jenkins
2. **Guardar imagen a archivo tar** con `docker save`
3. **Copiar tar al contenedor Minikube** con `docker cp`
4. **Importar imagen en Minikube** con `ctr images import`
5. **Limpiar archivos temporales**
6. **Verificar que la imagen existe** con `crictl images`

Esta estrategia funciona porque:
- Jenkins tiene Docker instalado
- No requiere el comando `minikube` en Jenkins
- Las imágenes quedan disponibles en el runtime de Minikube (containerd)
- `imagePullPolicy: Never` asegura que Kubernetes use las imágenes locales

## Pasos para Ejecutar el Pipeline

### 1. Ir a Jenkins
Abre tu navegador en: http://localhost:8079

### 2. Seleccionar el Pipeline
- Ve a la carpeta del servicio que quieres desplegar (ej: `user-service-dev`)
- O ejecuta el pipeline multibranch correspondiente

### 3. Ejecutar Build
- Haz clic en "Build Now" o "Build with Parameters"
- Si usas parámetros:
  - `SKIP_TESTS`: false (para ejecutar tests)
  - `SKIP_DEPLOY`: false (para desplegar)

### 4. Monitorear el Build
El pipeline ejecutará estos stages:
1. ✅ Checkout - Clonar código
2. ✅ Build Maven - Compilar con Maven
3. ✅ Unit Tests - Ejecutar tests unitarios (si no se saltó)
4. ✅ Build Docker Image - Construir y cargar imagen en Minikube
5. ✅ Deploy to Minikube - Crear deployment y service
6. ✅ Verify Deployment - Verificar que el pod esté Running
7. ✅ Integration Tests - Tests de integración (si no se saltó)

## Verificación Manual

Si quieres verificar manualmente que todo funciona:

```powershell
# Ver pods en ecommerce-dev
docker exec jenkins kubectl get pods -n ecommerce-dev

# Ver servicios
docker exec jenkins kubectl get svc -n ecommerce-dev

# Ver logs de un pod
docker exec jenkins kubectl logs -n ecommerce-dev -l app=user-service

# Ver detalles de un pod
docker exec jenkins kubectl describe pod -n ecommerce-dev -l app=user-service

# Ver imágenes en Minikube
docker exec minikube crictl images | grep service
```

## Troubleshooting

### Si el pod está en ImagePullBackOff
1. Verifica que la imagen se construyó correctamente en el stage "Build Docker Image"
2. Verifica que la imagen existe en Minikube:
   ```powershell
   docker exec minikube crictl images | grep <service-name>
   ```
3. Si la imagen no existe, ejecuta el pipeline nuevamente

### Si el pod está en CrashLoopBackOff
1. Revisa los logs del pod:
   ```powershell
   docker exec jenkins kubectl logs -n ecommerce-dev -l app=<service-name>
   ```
2. Verifica que el servicio tenga las dependencias necesarias (base de datos, etc.)

### Si el deployment no se crea
1. Verifica que el namespace existe:
   ```powershell
   docker exec jenkins kubectl get namespace ecommerce-dev
   ```
2. Verifica los eventos:
   ```powershell
   docker exec jenkins kubectl get events -n ecommerce-dev --sort-by='.lastTimestamp'
   ```

## Scripts Útiles

### Limpiar todos los deployments
```powershell
.\scripts\clean-all-deployments.ps1
```

### Verificar configuración de Jenkins + Minikube
```powershell
.\scripts\verify-jenkins-minikube.ps1
```

## Próximos Pasos

Una vez que el pipeline funcione correctamente:
1. Ejecuta el pipeline para cada servicio
2. Verifica que todos los pods estén en estado Running
3. Prueba la comunicación entre servicios
4. Ejecuta tests de integración end-to-end

## Documentación Relacionada
- `SOLUCION_KUBECONFIG_GKE_MINIKUBE.md` - Solución del problema de kubeconfig
- `SOLUCION_IMAGE_PULL_BACKOFF.md` - Solución del problema de ImagePullBackOff
- `CONFIGURAR_MINIKUBE_JENKINS.md` - Configuración inicial de Minikube con Jenkins
