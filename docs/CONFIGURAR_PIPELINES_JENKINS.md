# 🚀 Guía para Configurar los 18 Pipelines en Jenkins

## 📋 Resumen

Necesitas crear **18 pipelines** en Jenkins (6 servicios × 3 ambientes).

---

## 🎯 **PASO 1: Configurar Credenciales en Jenkins**

### 1.1 Agregar Credenciales de GitHub

1. Ir a **Jenkins** → **Manage Jenkins** → **Manage Credentials**
2. Click en **(global)** → **Add Credentials**
3. Configurar:
   - **Kind**: Username with password
   - **Username**: tu-usuario-github
   - **Password**: tu-token-github (o contraseña)
   - **ID**: `github-credentials`
   - **Description**: GitHub Credentials
4. **Save**

### 1.2 Verificar Credenciales de GCP

Ya tienes `jenkins-gcp-key.json`, así que Jenkins puede autenticarse con GCP.

---

## 🎯 **PASO 2: Crear Pipeline para user-service-dev**

### 2.1 Crear el Pipeline

1. **Jenkins** → **New Item**
2. **Nombre**: `user-service-dev-pipeline`
3. **Tipo**: **Multibranch Pipeline**
4. Click **OK**

### 2.2 Configurar Branch Sources

1. En **Branch Sources**, click **Add source** → **Git**
2. Configurar:
   - **Project Repository**: `https://github.com/tu-usuario/ecommerce-microservice-backend-app.git`
   - **Credentials**: Seleccionar `github-credentials`

### 2.3 Configurar Behaviors

1. Click **Add** → **Filter by name (with regular expression)**
2. **Regular expression**: `dev`
3. Esto hará que solo detecte la rama `dev`

### 2.4 Configurar Build Configuration

1. En **Build Configuration**:
   - **Mode**: `by Jenkinsfile`
   - **Script Path**: `user-service/Jenkinsfile.dev`

### 2.5 Configurar Scan

1. En **Scan Multibranch Pipeline Triggers**:
   - ✅ Marcar **Periodically if not otherwise run**
   - **Interval**: 1 minute (para pruebas, luego cambiar a 5-10 min)

### 2.6 Guardar

Click **Save**

---

## 🎯 **PASO 3: Repetir para todos los servicios**

Ahora repite el proceso para los otros 17 pipelines:

### **DEV Pipelines** (6 pipelines)

| Pipeline Name | Script Path | Rama |
|---------------|-------------|------|
| `user-service-dev-pipeline` | `user-service/Jenkinsfile.dev` | `dev` |
| `product-service-dev-pipeline` | `product-service/Jenkinsfile.dev` | `dev` |
| `order-service-dev-pipeline` | `order-service/Jenkinsfile.dev` | `dev` |
| `payment-service-dev-pipeline` | `payment-service/Jenkinsfile.dev` | `dev` |
| `favourite-service-dev-pipeline` | `favourite-service/Jenkinsfile.dev` | `dev` |
| `shipping-service-dev-pipeline` | `shipping-service/Jenkinsfile.dev` | `dev` |

### **STAGING Pipelines** (6 pipelines)

| Pipeline Name | Script Path | Rama |
|---------------|-------------|------|
| `user-service-staging-pipeline` | `user-service/Jenkinsfile.staging` | `staging` |
| `product-service-staging-pipeline` | `product-service/Jenkinsfile.staging` | `staging` |
| `order-service-staging-pipeline` | `order-service/Jenkinsfile.staging` | `staging` |
| `payment-service-staging-pipeline` | `payment-service/Jenkinsfile.staging` | `staging` |
| `favourite-service-staging-pipeline` | `favourite-service/Jenkinsfile.staging` | `staging` |
| `shipping-service-staging-pipeline` | `shipping-service/Jenkinsfile.staging` | `staging` |

### **MASTER Pipelines** (6 pipelines)

| Pipeline Name | Script Path | Rama |
|---------------|-------------|------|
| `user-service-master-pipeline` | `user-service/Jenkinsfile.master` | `master` |
| `product-service-master-pipeline` | `product-service/Jenkinsfile.master` | `master` |
| `order-service-master-pipeline` | `order-service/Jenkinsfile.master` | `master` |
| `payment-service-master-pipeline` | `payment-service/Jenkinsfile.master` | `master` |
| `favourite-service-master-pipeline` | `favourite-service/Jenkinsfile.master` | `master` |
| `shipping-service-master-pipeline` | `shipping-service/Jenkinsfile.master` | `master` |

---

## 🎯 **PASO 4: Probar el Primer Pipeline**

### 4.1 Hacer un Commit en la Rama DEV

```bash
git checkout dev
echo "# Test pipeline" >> README.md
git add .
git commit -m "test: probar pipeline dev"
git push origin dev
```

### 4.2 Verificar en Jenkins

1. Ir a **Jenkins** → `user-service-dev-pipeline`
2. Debería aparecer la rama `dev`
3. Click en la rama `dev`
4. Debería ejecutarse automáticamente

### 4.3 Ver el Log

Click en el build (#1) para ver el log de ejecución.

---

## 🎯 **PASO 5: Probar el Flujo Completo**

### 5.1 DEV → STAGING

```bash
# Merge de dev a staging
git checkout staging
git merge dev
git push origin staging
```

**Verificar**: El pipeline `user-service-staging-pipeline` debería ejecutarse.

### 5.2 STAGING → MASTER

```bash
# Merge de staging a master
git checkout master
git merge staging
git push origin master
```

**Verificar**: 
- El pipeline `user-service-master-pipeline` debería ejecutarse
- Se debe generar `release-notes/user-service-v1.0.0.md`

---

## 📊 **Checklist de Verificación**

| # | Tarea | Estado |
|---|-------|--------|
| 1 | Credenciales GitHub configuradas | ❌ |
| 2 | 6 pipelines DEV creados | ❌ |
| 3 | 6 pipelines STAGING creados | ❌ |
| 4 | 6 pipelines MASTER creados | ❌ |
| 5 | Pipeline DEV funciona | ❌ |
| 6 | Pipeline STAGING funciona | ❌ |
| 7 | Pipeline MASTER funciona | ❌ |
| 8 | Release Notes generadas | ❌ |

---

## 🚨 **Troubleshooting**

### Error: "Cannot connect to repository"
- Verificar credenciales de GitHub
- Verificar que la URL del repositorio es correcta

### Error: "Jenkinsfile not found"
- Verificar que el Script Path es correcto
- Ejemplo: `user-service/Jenkinsfile.dev` (no `user-service\Jenkinsfile.dev`)

### Error: "kubectl: command not found"
- Verificar que gcloud está configurado en Jenkins
- Ejecutar: `gcloud components install kubectl`

### Error: "Cannot push to registry"
- Verificar que Docker está autenticado con GCR
- Ejecutar: `gcloud auth configure-docker us-central1-docker.pkg.dev`

---

## 💡 **Tips**

1. **Empieza con un solo servicio**: Configura y prueba `user-service` primero
2. **Usa la misma configuración**: Una vez que funcione, replica a los demás
3. **Verifica los logs**: Si algo falla, revisa los logs del pipeline
4. **Paciencia**: El primer build puede tardar más (descarga dependencias)

---

## ✅ **Próximo Paso**

**Ahora debes**:
1. Ir a Jenkins (http://localhost:8080)
2. Crear el primer pipeline: `user-service-dev-pipeline`
3. Hacer un commit en la rama `dev`
4. Verificar que el pipeline se ejecuta

**Avísame cuando hayas creado el primer pipeline y te ayudo a verificar que funciona.**

---

*Última actualización: 30 de Octubre, 2025*
