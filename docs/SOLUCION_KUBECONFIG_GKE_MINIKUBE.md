# Solución: Error gke-gcloud-auth-plugin en Jenkins con Minikube

## Problema
Jenkins intentaba conectarse a GKE en lugar de Minikube, generando el error:
```
Unable to connect to the server: getting credentials: exec: executable gke-gcloud-auth-plugin not found
```

## Causa
El archivo kubeconfig en Jenkins (`/var/jenkins_home/.kube/config`) tenía configuración de GKE que tomaba precedencia sobre Minikube.

## Solución Aplicada

### 1. Copiar Certificados de Minikube a Jenkins
```powershell
# Crear directorio para certificados
docker exec jenkins mkdir -p /var/jenkins_home/.minikube/certs

# Copiar certificados
docker cp minikube:/var/lib/minikube/certs/ca.crt temp-ca.crt
docker cp temp-ca.crt jenkins:/var/jenkins_home/.minikube/certs/ca.crt

docker cp minikube:/var/lib/minikube/certs/apiserver.crt temp-client.crt
docker cp temp-client.crt jenkins:/var/jenkins_home/.minikube/certs/client.crt

docker cp minikube:/var/lib/minikube/certs/apiserver.key temp-client.key
docker cp temp-client.key jenkins:/var/jenkins_home/.minikube/certs/client.key
```

### 2. Configurar kubectl para Usar Minikube
```powershell
# Obtener IP de Minikube
$minikubeIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minikube

# Configurar cluster
docker exec jenkins sh -c "kubectl config set-cluster minikube --server=https://192.168.67.2:8443 --certificate-authority=/var/jenkins_home/.minikube/certs/ca.crt"

# Configurar credenciales
docker exec jenkins sh -c "kubectl config set-credentials minikube --client-certificate=/var/jenkins_home/.minikube/certs/client.crt --client-key=/var/jenkins_home/.minikube/certs/client.key"

# Configurar contexto
docker exec jenkins sh -c "kubectl config set-context minikube --cluster=minikube --user=minikube"

# Usar contexto Minikube
docker exec jenkins sh -c "kubectl config use-context minikube"
```

### 3. Eliminar Referencias a GKE
```powershell
# Eliminar contexto GKE
docker exec jenkins sh -c "kubectl config delete-context gke_ecommerce-microservices-476519_us-central1-a_ecommerce-staging-cluster"

# Eliminar cluster GKE
docker exec jenkins sh -c "kubectl config delete-cluster gke_ecommerce-microservices-476519_us-central1-a_ecommerce-staging-cluster"

# Eliminar usuario GKE
docker exec jenkins sh -c "kubectl config unset users.gke_ecommerce-microservices-476519_us-central1-a_ecommerce-staging-cluster"
```

### 4. Verificar Configuración
```powershell
# Ver configuración actual
docker exec jenkins kubectl config view

# Verificar conexión
docker exec jenkins kubectl cluster-info

# Listar nodos
docker exec jenkins kubectl get nodes

# Listar namespaces
docker exec jenkins kubectl get namespaces
```

## Resultado
✅ kubectl ahora se conecta correctamente a Minikube
✅ No hay referencias a GKE en el kubeconfig
✅ Jenkins puede desplegar en Minikube sin errores

## Configuración Final del kubeconfig
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/jenkins_home/.minikube/certs/ca.crt
    server: https://192.168.67.2:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
users:
- name: minikube
  user:
    client-certificate: /var/jenkins_home/.minikube/certs/client.crt
    client-key: /var/jenkins_home/.minikube/certs/client.key
```

## Notas Importantes
- Los certificados están en `/var/jenkins_home/.minikube/certs/`
- La IP de Minikube es `192.168.67.2` (puede cambiar si se reinicia el contenedor)
- El contexto actual es `minikube`
- No se requiere el plugin `gke-gcloud-auth-plugin`

## Verificación Final
Para verificar que todo está funcionando correctamente, ejecuta:
```powershell
.\scripts\verify-jenkins-minikube.ps1
```

Este script verifica:
- Estado de contenedores Jenkins y Minikube
- IP de Minikube
- Configuración de kubeconfig
- Conexión a Minikube
- Namespaces disponibles
- Certificados instalados

## Estado Actual
✅ Jenkins configurado correctamente
✅ Kubeconfig limpio (solo Minikube)
✅ Certificados copiados y funcionando
✅ Conexión verificada
✅ Namespaces creados (ecommerce-dev, ecommerce-staging)

## Próximos Pasos
Ahora puedes ejecutar el pipeline de Jenkins y debería funcionar correctamente con Minikube.

## Commit Realizado
```
fix: Solucionar error gke-gcloud-auth-plugin en Jenkins

- Eliminar configuracion de GKE del kubeconfig
- Configurar kubectl para usar solo Minikube con certificados
- Agregar scripts para limpiar y configurar kubeconfig
- Documentar solucion completa en SOLUCION_KUBECONFIG_GKE_MINIKUBE.md
```
