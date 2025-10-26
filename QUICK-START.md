# 🚀 Quick Start - Jenkins CI/CD

## ⚡ Inicio Rápido (5 minutos)

### Paso 1: Levantar Jenkins

```powershell
# Desde PowerShell en la raíz del proyecto
.\scripts\setup-jenkins.ps1
```

O manualmente:

```powershell
docker-compose -f docker-compose.jenkins.yml up -d
```

---

### Paso 2: Obtener Contraseña

```powershell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copia la contraseña que aparece.

---

### Paso 3: Configurar Jenkins

1. Abre: **http://localhost:8079**
2. Pega la contraseña
3. Click en **"Install suggested plugins"**
4. Espera 2-3 minutos
5. Crea usuario admin:
   - Username: `admin`
   - Password: `admin123`
6. Click en **"Save and Continue"** → **"Start using Jenkins"**

---

### Paso 4: Configurar Credenciales

#### Docker Hub:
1. **Manage Jenkins** → **Manage Credentials** → **System** → **Global credentials** → **Add Credentials**
2. Configurar:
   - Kind: `Username with password`
   - Username: `tu_usuario_dockerhub`
   - Password: `tu_password_dockerhub`
   - ID: `docker-hub-credentials`
3. Click **"Create"**

#### GitHub Token:
1. Crear token en: https://github.com/settings/tokens
   - Scopes: `repo`, `admin:repo_hook`
2. En Jenkins: **Add Credentials**
   - Kind: `Secret text`
   - Secret: `tu_token_github`
   - ID: `github-token`
3. Click **"Create"**

---

### Paso 5: Crear Pipeline

1. Click en **"New Item"**
2. Name: `ecommerce-microservices`
3. Type: **Multibranch Pipeline**
4. Click **"OK"**
5. En **Branch Sources**:
   - Add source → **Git**
   - Repository URL: `https://github.com/Andres-Chamorro/ecommerce-microservice-backend-app.git`
6. En **Build Configuration**:
   - Script Path: `Jenkinsfile`
7. Click **"Save"**

---

### Paso 6: Ejecutar Pipeline

1. Jenkins escaneará automáticamente las ramas
2. Verás 3 pipelines: `dev`, `staging`, `master`
3. Click en `dev` → **"Build Now"**
4. Ver progreso en **"Console Output"**

---

## 📊 Ver Resultados

- **Dashboard:** http://localhost:8079/job/ecommerce-microservices/
- **Dev builds:** http://localhost:8079/job/ecommerce-microservices/job/dev/
- **Staging builds:** http://localhost:8079/job/ecommerce-microservices/job/staging/
- **Master builds:** http://localhost:8079/job/ecommerce-microservices/job/master/

---

## 🛑 Detener Jenkins

```powershell
docker-compose -f docker-compose.jenkins.yml down
```

---

## 🔄 Reiniciar Jenkins

```powershell
docker restart jenkins
```

---

## 📖 Documentación Completa

Para más detalles, lee: **docs/JENKINS-SETUP.md**

---

## ⚠️ Troubleshooting

### Jenkins no inicia:
```powershell
docker logs jenkins
```

### Error de permisos:
```powershell
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Reinstalar Jenkins:
```powershell
docker-compose -f docker-compose.jenkins.yml down -v
docker-compose -f docker-compose.jenkins.yml up -d
```

---

## 🎯 Para el Reporte

Toma screenshots de:
1. ✅ Jenkins Dashboard
2. ✅ Pipeline ejecutándose
3. ✅ Console output
4. ✅ Test results
5. ✅ Integration tests
6. ✅ Release notes

---

## 📞 ¿Necesitas Ayuda?

1. Revisa: **docs/JENKINS-SETUP.md**
2. Revisa logs: `docker logs jenkins`
3. Verifica Docker Desktop esté corriendo
