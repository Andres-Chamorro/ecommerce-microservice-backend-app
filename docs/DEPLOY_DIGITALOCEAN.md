# 🌊 Guía de Despliegue en DigitalOcean

## 📋 Requisitos Previos

- Cuenta en DigitalOcean
- Cuenta en Docker Hub (para las imágenes)
- Git instalado localmente

---

## 🚀 Opción 1: Jenkins en Droplet de DigitalOcean

### Paso 1: Crear Droplet

1. Ir a DigitalOcean → **Create** → **Droplets**
2. Seleccionar:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic
   - **CPU**: Regular (4 GB RAM / 2 vCPUs) - Mínimo recomendado
   - **Datacenter**: Closest to you
   - **Authentication**: SSH Key (recomendado) o Password
3. **Create Droplet**

### Paso 2: Conectar al Droplet

```bash
ssh root@your-droplet-ip
```

### Paso 3: Instalar Docker

```bash
# Actualizar sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Verificar instalación
docker --version
```

### Paso 4: Instalar Docker Compose

```bash
# Instalar Docker Compose
apt install docker-compose -y

# Verificar
docker-compose --version
```

### Paso 5: Instalar Jenkins

```bash
# Crear directorio para Jenkins
mkdir -p /opt/jenkins
cd /opt/jenkins

# Crear docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts-jdk11
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
    restart: unless-stopped

volumes:
  jenkins_home:
EOF

# Levantar Jenkins
docker-compose up -d

# Ver logs
docker-compose logs -f jenkins
```

### Paso 6: Configurar Firewall

```bash
# Permitir tráfico en puerto 8080
ufw allow 8080/tcp
ufw allow 22/tcp
ufw enable
```

### Paso 7: Acceder a Jenkins

1. Ir a: `http://your-droplet-ip:8080`
2. Obtener password inicial:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
3. Instalar plugins sugeridos
4. Crear usuario admin

### Paso 8: Instalar Plugins Necesarios

En Jenkins:
1. **Manage Jenkins** → **Manage Plugins** → **Available**
2. Instalar:
   - Docker Pipeline
   - Kubernetes CLI
   - Git
   - Maven Integration
   - Pipeline

### Paso 9: Instalar Docker CLI en Jenkins

```bash
# Entrar al contenedor de Jenkins
docker exec -it -u root jenkins bash

# Instalar Docker CLI
apt-get update
apt-get install -y docker.io

# Salir
exit
```

### Paso 10: Instalar kubectl en Jenkins

```bash
docker exec -it -u root jenkins bash

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verificar
kubectl version --client

exit
```

### Paso 11: Instalar Maven en Jenkins

```bash
docker exec -it -u root jenkins bash

apt-get update
apt-get install -y maven

# Verificar
mvn -version

exit
```

---

## ☸️ Opción 2: Kubernetes en DigitalOcean (DOKS)

### Paso 1: Crear Cluster de Kubernetes

1. En DigitalOcean → **Kubernetes** → **Create Cluster**
2. Configuración:
   - **Kubernetes version**: Latest stable
   - **Datacenter region**: Closest to you
   - **Node pool**: 
     - Node plan: Basic (4 GB RAM / 2 vCPUs)
     - Node count: 3
3. **Create Cluster**

### Paso 2: Configurar kubectl Local

```bash
# Descargar kubeconfig desde DigitalOcean
# En DigitalOcean, ir a tu cluster → Getting Started → Download Config File

# Mover el archivo
mkdir -p ~/.kube
mv ~/Downloads/k8s-1-xx-x-do-x-xxx-kubeconfig.yaml ~/.kube/config

# Verificar conexión
kubectl get nodes
```

### Paso 3: Configurar kubectl en Jenkins

```bash
# Copiar el kubeconfig al contenedor de Jenkins
docker cp ~/.kube/config jenkins:/var/jenkins_home/.kube/config

# Dar permisos
docker exec -it jenkins bash
chown jenkins:jenkins /var/jenkins_home/.kube/config
chmod 600 /var/jenkins_home/.kube/config
exit
```

---

## 🔧 Configurar Pipeline en Jenkins

### Paso 1: Crear Credenciales de Docker Hub

1. Jenkins → **Manage Jenkins** → **Manage Credentials**
2. **(global)** → **Add Credentials**
3. Tipo: **Username with password**
   - Username: Tu usuario de Docker Hub
   - Password: Tu token de Docker Hub
   - ID: `dockerhub`

### Paso 2: Subir Código a GitHub/GitLab

```bash
# En tu máquina local
cd c:\Users\chamo\Videos\ecommerce-microservice-backend-app

# Inicializar git (si no está)
git init
git add .
git commit -m "Initial commit with Jenkins and K8s config"

# Crear repositorio en GitHub y subir
git remote add origin https://github.com/tu-usuario/ecommerce-microservices.git
git branch -M main
git push -u origin main
```

### Paso 3: Crear Pipeline Job en Jenkins

1. Jenkins → **New Item**
2. Nombre: `ecommerce-microservices-pipeline`
3. Tipo: **Pipeline**
4. En **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/tu-usuario/ecommerce-microservices.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. **Save**

### Paso 4: Ejecutar Pipeline

1. Click en **Build with Parameters**
2. Seleccionar opciones:
   - DEPLOY_SERVICES: `ALL`
   - SKIP_TESTS: `false`
   - DEPLOY_TO_K8S: `true`
3. **Build**

---

## 🐳 Subir Imágenes a Docker Hub

### Opción Manual (antes del pipeline)

```bash
# En tu máquina local
docker login

# Etiquetar imágenes
docker tag ecommerce-user-service:latest tu-usuario/ecommerce-user-service:latest
docker tag ecommerce-product-service:latest tu-usuario/ecommerce-product-service:latest
docker tag ecommerce-order-service:latest tu-usuario/ecommerce-order-service:latest
docker tag ecommerce-payment-service:latest tu-usuario/ecommerce-payment-service:latest
docker tag ecommerce-favourite-service:latest tu-usuario/ecommerce-favourite-service:latest
docker tag ecommerce-shipping-service:latest tu-usuario/ecommerce-shipping-service:latest

# Subir
docker push tu-usuario/ecommerce-user-service:latest
docker push tu-usuario/ecommerce-product-service:latest
docker push tu-usuario/ecommerce-order-service:latest
docker push tu-usuario/ecommerce-payment-service:latest
docker push tu-usuario/ecommerce-favourite-service:latest
docker push tu-usuario/ecommerce-shipping-service:latest
```

### Actualizar Manifiestos de Kubernetes

Editar cada archivo en `k8s/*-deployment.yaml` y cambiar:
```yaml
image: ecommerce-user-service:latest
```
Por:
```yaml
image: tu-usuario/ecommerce-user-service:latest
```

---

## 📊 Acceder a los Servicios

### Ver Servicios en Kubernetes

```bash
kubectl get svc -n ecommerce-dev
```

### Obtener IP Externa del API Gateway

```bash
kubectl get svc api-gateway -n ecommerce-dev
```

Si usas LoadBalancer, obtendrás una IP externa de DigitalOcean.

### Acceder a la aplicación

```
http://EXTERNAL-IP:8080
```

---

## 🔒 Configurar Dominio (Opcional)

### Paso 1: Configurar DNS

1. En tu proveedor de dominio, crear registro A:
   - Host: `@` o `api`
   - Value: IP del LoadBalancer
   - TTL: 300

### Paso 2: Instalar Ingress Controller

```bash
# Instalar NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/do/deploy.yaml

# Verificar
kubectl get svc -n ingress-nginx
```

### Paso 3: Crear Ingress

Crear `k8s/ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce-dev
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: api.tudominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway
            port:
              number: 8080
```

Aplicar:
```bash
kubectl apply -f k8s/ingress.yaml
```

---

## 💰 Costos Estimados en DigitalOcean

### Opción 1: Solo Droplet con Jenkins
- **Droplet** (4 GB RAM): ~$24/mes
- **Total**: ~$24/mes

### Opción 2: Droplet + Kubernetes
- **Droplet Jenkins** (2 GB RAM): ~$12/mes
- **Kubernetes Cluster** (3 nodos de 4 GB): ~$72/mes
- **LoadBalancer**: ~$12/mes
- **Total**: ~$96/mes

### Opción 3: Todo en Kubernetes
- **Kubernetes Cluster** (3 nodos de 4 GB): ~$72/mes
- **LoadBalancer**: ~$12/mes
- **Total**: ~$84/mes

---

## 🧪 Testing del Despliegue

```bash
# Verificar pods
kubectl get pods -n ecommerce-dev

# Ver logs
kubectl logs -f deployment/user-service -n ecommerce-dev

# Probar API Gateway
curl http://EXTERNAL-IP:8080/actuator/health

# Probar un microservicio
curl http://EXTERNAL-IP:8080/user-service/actuator/health
```

---

## 🔧 Troubleshooting

### Jenkins no puede conectar a Docker

```bash
# Dar permisos al socket de Docker
chmod 666 /var/run/docker.sock
```

### Pods en estado Pending

```bash
# Ver eventos
kubectl describe pod <pod-name> -n ecommerce-dev

# Verificar recursos
kubectl top nodes
```

### Pipeline falla en push a Docker Hub

Verificar credenciales en Jenkins:
```bash
# Probar login manual
docker login
```

---

## 📚 Comandos Útiles

```bash
# Ver logs de Jenkins
docker logs -f jenkins

# Reiniciar Jenkins
docker restart jenkins

# Ver todos los recursos en K8s
kubectl get all -n ecommerce-dev

# Escalar servicio
kubectl scale deployment user-service --replicas=3 -n ecommerce-dev

# Eliminar todo
kubectl delete namespace ecommerce-dev
```

---

## ✅ Checklist de Despliegue

- [ ] Droplet creado en DigitalOcean
- [ ] Docker y Docker Compose instalados
- [ ] Jenkins corriendo en puerto 8080
- [ ] Plugins instalados en Jenkins
- [ ] Docker CLI instalado en Jenkins
- [ ] kubectl instalado en Jenkins
- [ ] Maven instalado en Jenkins
- [ ] Cluster de Kubernetes creado (DOKS)
- [ ] kubeconfig configurado en Jenkins
- [ ] Credenciales de Docker Hub en Jenkins
- [ ] Código subido a GitHub/GitLab
- [ ] Pipeline job creado en Jenkins
- [ ] Imágenes subidas a Docker Hub
- [ ] Microservicios desplegados en K8s
- [ ] API Gateway accesible

---

**¡Listo para desplegar en DigitalOcean! 🚀**
