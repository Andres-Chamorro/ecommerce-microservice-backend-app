# 🚀 Guía de Instalación de Jenkins

Esta guía te ayudará a configurar Jenkins localmente para ejecutar el pipeline CI/CD.

---

## 📋 Requisitos Previos

Asegúrate de tener instalado:
- ✅ Docker Desktop (Windows)
- ✅ Git
- ✅ Cuenta de Docker Hub
- ✅ Cuenta de GitHub

---

## 🔧 Paso 1: Levantar Jenkins

### Opción A: Con Docker Compose (Recomendado)

```bash
# Desde la raíz del proyecto
docker-compose -f docker-compose.jenkins.yml up -d
```

### Opción B: Con Docker Run

```bash
docker run -d -p 8079:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:lts
```

---

## 🔑 Paso 2: Obtener Contraseña Inicial

```bash
# Ver la contraseña inicial
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copia la contraseña que aparece.

---

## 🌐 Paso 3: Configurar Jenkins

1. **Abrir Jenkins:**
   ```
   http://localhost:8079
   ```

2. **Pegar la contraseña inicial** que copiaste

3. **Seleccionar:** "Install suggested plugins"

4. **Esperar** a que se instalen los plugins (2-3 minutos)

5. **Crear usuario admin:**
   - Username: `admin`
   - Password: `admin123` (o la que prefieras)
   - Full name: `Tu Nombre`
   - Email: `tu@email.com`

6. **Confirmar URL:** `http://localhost:8079/`

---

## 🔌 Paso 4: Instalar Plugins Adicionales

1. Ir a: **Manage Jenkins** → **Manage Plugins** → **Available**

2. Buscar e instalar:
   - ✅ **Docker Pipeline**
   - ✅ **Kubernetes**
   - ✅ **GitHub**
   - ✅ **Pipeline**
   - ✅ **Git**
   - ✅ **Credentials Binding**
   - ✅ **JUnit**

3. Click en **"Install without restart"**

4. Marcar: **"Restart Jenkins when installation is complete"**

---

## 🔐 Paso 5: Configurar Credenciales

### 5.1 Docker Hub Credentials

1. Ir a: **Manage Jenkins** → **Manage Credentials** → **System** → **Global credentials**

2. Click en **"Add Credentials"**

3. Configurar:
   - **Kind:** Username with password
   - **Scope:** Global
   - **Username:** tu_usuario_dockerhub
   - **Password:** tu_password_dockerhub
   - **ID:** `docker-hub-credentials`
   - **Description:** Docker Hub Credentials

4. Click en **"Create"**

---

### 5.2 GitHub Token

1. **Crear token en GitHub:**
   - Ir a: https://github.com/settings/tokens
   - Click en **"Generate new token (classic)"**
   - Nombre: `Jenkins CI/CD`
   - Scopes:
     - ✅ `repo` (todos)
     - ✅ `admin:repo_hook`
   - Click en **"Generate token"**
   - **COPIAR EL TOKEN** (no podrás verlo de nuevo)

2. **Agregar en Jenkins:**
   - Ir a: **Manage Jenkins** → **Manage Credentials** → **System** → **Global credentials**
   - Click en **"Add Credentials"**
   - Configurar:
     - **Kind:** Secret text
     - **Scope:** Global
     - **Secret:** [pegar tu token de GitHub]
     - **ID:** `github-token`
     - **Description:** GitHub Token
   - Click en **"Create"**

---

### 5.3 Kubeconfig (Opcional - para Kubernetes)

Si tienes Kubernetes configurado:

1. Obtener tu kubeconfig:
   ```bash
   cat ~/.kube/config
   ```

2. En Jenkins:
   - **Kind:** Secret file
   - **File:** [subir tu archivo kubeconfig]
   - **ID:** `kubeconfig`
   - **Description:** Kubernetes Config

---

## 📦 Paso 6: Crear Pipeline Job

1. En Jenkins, click en **"New Item"**

2. Configurar:
   - **Name:** `ecommerce-microservices`
   - **Type:** Multibranch Pipeline
   - Click en **"OK"**

3. En **Branch Sources:**
   - Click en **"Add source"** → **Git**
   - **Project Repository:** `https://github.com/Andres-Chamorro/ecommerce-microservice-backend-app.git`
   - **Credentials:** (seleccionar tu GitHub token si el repo es privado)

4. En **Build Configuration:**
   - **Mode:** by Jenkinsfile
   - **Script Path:** `Jenkinsfile`

5. En **Scan Multibranch Pipeline Triggers:**
   - ✅ Marcar: "Periodically if not otherwise run"
   - **Interval:** 1 minute

6. Click en **"Save"**

---

## 🚀 Paso 7: Ejecutar el Pipeline

1. Jenkins escaneará automáticamente las ramas (dev, staging, master)

2. Verás 3 pipelines creados:
   - `dev`
   - `staging`
   - `master`

3. Click en cualquier rama para ver el pipeline

4. Click en **"Build Now"** para ejecutar manualmente

---

## 📊 Paso 8: Ver Resultados

### Ver Build en Progreso:
```
http://localhost:8079/job/ecommerce-microservices/job/dev/
```

### Ver Console Output:
Click en el número del build → **"Console Output"**

### Ver Test Results:
Click en el build → **"Test Result"**

### Ver Artifacts:
Click en el build → **"Build Artifacts"**

---

## 🔄 Paso 9: Configurar Webhook (Opcional)

Para que Jenkins ejecute automáticamente cuando hagas push:

1. En tu repositorio GitHub:
   - Ir a: **Settings** → **Webhooks** → **Add webhook**

2. Configurar:
   - **Payload URL:** `http://TU_IP_PUBLICA:8079/github-webhook/`
   - **Content type:** application/json
   - **Events:** Just the push event
   - Click en **"Add webhook"**

**Nota:** Necesitas exponer tu Jenkins a internet (ngrok, cloudflare tunnel, etc.)

---

## 🐛 Troubleshooting

### Jenkins no inicia:
```bash
# Ver logs
docker logs jenkins

# Reiniciar Jenkins
docker restart jenkins
```

### Error de permisos con Docker:
```bash
# Dar permisos al usuario jenkins
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Pipeline falla en Docker build:
```bash
# Instalar Docker CLI en Jenkins
docker exec -u root jenkins apt-get update
docker exec -u root jenkins apt-get install -y docker.io
```

### No encuentra kubectl:
```bash
# Instalar kubectl en Jenkins
docker exec -u root jenkins curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
docker exec -u root jenkins install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

## 📸 Capturas de Pantalla para el Reporte

Toma screenshots de:

1. ✅ Jenkins Dashboard con los 3 pipelines
2. ✅ Build exitoso en staging
3. ✅ Console output mostrando los stages
4. ✅ Test results
5. ✅ Integration tests ejecutándose
6. ✅ Release notes generadas
7. ✅ Pods desplegados en Kubernetes (si aplica)

---

## 🎯 Verificación Final

Checklist antes de entregar:

- [ ] Jenkins corriendo en `http://localhost:8079`
- [ ] Credenciales configuradas (Docker Hub, GitHub)
- [ ] Pipeline creado y conectado al repositorio
- [ ] Build exitoso en rama `dev`
- [ ] Build exitoso en rama `staging` con integration tests
- [ ] Build exitoso en rama `master` con release notes
- [ ] Screenshots tomados
- [ ] Documentación completa

---

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs: `docker logs jenkins`
2. Revisa el console output del build en Jenkins
3. Verifica que las credenciales estén correctas
4. Asegúrate de que Docker Desktop esté corriendo

---

## 🎓 Para el Reporte

Incluye en tu reporte:

### Sección 1: Configuración del Ambiente
- Screenshots de Jenkins instalado
- Credenciales configuradas
- Pipeline creado

### Sección 2: Ejecución del Pipeline
- Build en rama `dev` (solo build y tests)
- Build en rama `staging` (deploy + integration tests)
- Build en rama `master` (deploy production + release notes)

### Sección 3: Resultados
- Test results
- Integration test results
- Release notes generadas
- Pods desplegados (si aplica)

### Sección 4: Conclusiones
- Lecciones aprendidas
- Problemas encontrados y soluciones
- Mejoras futuras
