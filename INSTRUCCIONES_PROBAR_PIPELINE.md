# Instrucciones para Probar el Pipeline

## Estado Actual ✅

Todos los componentes están configurados y listos:

1. ✅ Jenkins con Maven, Docker CLI y kubectl instalados
2. ✅ Minikube corriendo
3. ✅ Jenkinsfiles actualizados en todos los servicios
4. ✅ Comandos kubectl usando `docker exec minikube kubectl`

## Servicios Configurados

Cada servicio tiene su `Jenkinsfile` configurado:

| Servicio | Puerto | Jenkinsfile |
|----------|--------|-------------|
| user-service | 8300 | ✅ user-service/Jenkinsfile |
| order-service | 8100 | ✅ order-service/Jenkinsfile |
| product-service | 8200 | ✅ product-service/Jenkinsfile |
| payment-service | 8400 | ✅ payment-service/Jenkinsfile |
| shipping-service | 8500 | ✅ shipping-service/Jenkinsfile |
| favourite-service | 8600 | ✅ favourite-service/Jenkinsfile |

## Pasos para Probar

### 1. Verificar que todo está corriendo

```powershell
# Verificar Jenkins
docker ps | grep jenkins

# Verificar Minikube
minikube status

# Verificar herramientas en Jenkins
docker exec jenkins mvn --version
docker exec jenkins kubectl version --client
docker exec jenkins docker --version
```

### 2. Acceder a Jenkins

1. Abre tu navegador en: **http://localhost:8079**
2. Si es la primera vez, necesitarás la contraseña inicial:
   ```powershell
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

### 3. Crear Pipeline en Jenkins (si no existe)

Para cada servicio, crea un pipeline:

1. Click en "New Item"
2. Nombre: `user-service-pipeline` (o el nombre del servicio)
3. Tipo: "Pipeline"
4. Click "OK"
5. En la configuración:
   - **Pipeline Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: (tu repositorio)
   - **Script Path**: `user-service/Jenkinsfile`
6. Click "Save"

### 4. Ejecutar el Pipeline

1. Selecciona el pipeline (ej: `user-service-pipeline`)
2. Click en "Build with Parameters"
3. Configura los parámetros:
   - **SKIP_TESTS**: `false` (para ejecutar tests)
   - **SKIP_DEPLOY**: `false` (para desplegar en Minikube)
4. Click en "Build"

### 5. Monitorear la Ejecución

El pipeline ejecutará estos stages:

1. **Checkout** - Clona el código
2. **Build Maven** - Compila con Maven
3. **Unit Tests** - Ejecuta tests unitarios
4. **Build Docker Image** - Construye y carga imagen en Minikube
5. **Deploy to Minikube** - Despliega en Kubernetes
6. **Verify Deployment** - Verifica que el pod está Running
7. **Integration Tests** - Tests de integración (si existen)

### 6. Verificar el Despliegue

Después de que el pipeline termine exitosamente:

```powershell
# Ver pods en Minikube
docker exec minikube kubectl get pods -n ecommerce-dev

# Ver servicios
docker exec minikube kubectl get svc -n ecommerce-dev

# Ver logs del pod
docker exec minikube kubectl logs -n ecommerce-dev -l app=user-service

# Describir el pod
docker exec minikube kubectl describe pod -n ecommerce-dev -l app=user-service
```

## Troubleshooting

### Error: mvn not found
**Solución:** Reconstruir Jenkins con las herramientas
```powershell
./scripts/rebuild-jenkins-with-tools.ps1
```

### Error: docker exec minikube: container not found
**Solución:** Iniciar Minikube
```powershell
minikube start
```

### Error: Image pull failed
**Solución:** Verificar que la imagen se cargó en Minikube
```powershell
docker exec minikube crictl images | grep user-service
```

### Error: namespace not found
**Solución:** El pipeline crea el namespace automáticamente, pero puedes crearlo manualmente:
```powershell
docker exec minikube kubectl create namespace ecommerce-dev
```

### Pipeline falla en Build Maven
**Causas comunes:**
- Errores de compilación en el código
- Dependencias faltantes en pom.xml
- Tests unitarios fallando

**Solución:** Revisa los logs del pipeline en Jenkins para ver el error específico.

### Pipeline falla en Deploy
**Causas comunes:**
- Imagen no se cargó correctamente en Minikube
- Namespace no existe
- Recursos insuficientes en Minikube

**Solución:** 
```powershell
# Ver recursos de Minikube
docker exec minikube kubectl top nodes

# Ver eventos
docker exec minikube kubectl get events -n ecommerce-dev --sort-by='.lastTimestamp'
```

## Comandos Útiles

### Jenkins
```powershell
# Ver logs de Jenkins
docker logs jenkins -f

# Reiniciar Jenkins
docker restart jenkins

# Entrar al contenedor de Jenkins
docker exec -it jenkins bash
```

### Minikube
```powershell
# Ver todos los pods
docker exec minikube kubectl get pods -A

# Eliminar un deployment
docker exec minikube kubectl delete deployment user-service -n ecommerce-dev

# Limpiar namespace completo
docker exec minikube kubectl delete namespace ecommerce-dev
```

### Debugging
```powershell
# Ver logs del pipeline en tiempo real
# (desde la UI de Jenkins, click en el build y luego "Console Output")

# Ver imágenes en Minikube
docker exec minikube crictl images

# Ver contenedores corriendo en Minikube
docker exec minikube crictl ps
```

## Próximos Pasos

Una vez que el pipeline funcione correctamente:

1. ✅ Probar con user-service
2. ⏳ Probar con los demás servicios
3. ⏳ Configurar webhooks para builds automáticos
4. ⏳ Agregar stages para staging y production
5. ⏳ Configurar notificaciones (email, Slack, etc.)
6. ⏳ Agregar análisis de código (SonarQube)
7. ⏳ Configurar reportes de cobertura de tests

## Notas Importantes

- Los Jenkinsfiles están configurados para ambiente **DEV** (desarrollo local)
- Las imágenes se cargan directamente en Minikube (no se suben a registry)
- El namespace usado es `ecommerce-dev`
- Los servicios usan `imagePullPolicy: Never` para usar imágenes locales
- Los tests de integración solo se ejecutan si existe el archivo `tests/integration/pom.xml`
