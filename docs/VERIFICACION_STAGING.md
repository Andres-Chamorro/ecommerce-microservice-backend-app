# Verificación de Configuración STAGING

## ✅ Checklist para Rama Staging

### 1. Configuración de GCP
- [ ] Proyecto GCP: `ecommerce-microservices-476519`
- [ ] Cluster GKE creado
- [ ] Docker Registry configurado: `us-central1-docker.pkg.dev/ecommerce-microservices-476519/ecommerce-registry`

### 2. Configuración de Jenkins
- [ ] gcloud SDK instalado en Jenkins
- [ ] kubectl configurado con acceso a GKE
- [ ] Credenciales de GCP configuradas

### 3. Jenkinsfiles de Staging
- [ ] 6 servicios tienen Jenkinsfile.staging
- [ ] Configurados para GKE
- [ ] Registry correcto configurado

## 🔍 Comandos de Verificación

### Verificar acceso a GKE desde Jenkins:
```bash
docker exec jenkins bash -c ". /root/google-cloud-sdk/path.bash.inc && kubectl cluster-info"
```

### Verificar acceso al Docker Registry:
```bash
docker exec jenkins bash -c ". /root/google-cloud-sdk/path.bash.inc && gcloud auth list"
```

### Verificar namespace en GKE:
```bash
docker exec jenkins bash -c ". /root/google-cloud-sdk/path.bash.inc && kubectl get namespace ecommerce-staging"
```

## 📋 Stages de Staging (según tu estrategia)

1. ✅ Checkout
2. ✅ Pull Image from Dev (o Build si no existe)
3. ✅ Retag Image para staging
4. ✅ Deploy to GKE Staging
5. ✅ Wait for Rollout
6. ✅ E2E Tests
7. ✅ Performance Tests (Locust)
8. ✅ Generate Test Report
9. ✅ Verify Health Checks

## 🚀 Próximos Pasos

1. **Crear rama staging** si no existe:
   ```bash
   git checkout -b staging
   git push origin staging
   ```

2. **Configurar Multibranch Pipeline en Jenkins** para detectar la rama staging

3. **Ejecutar primer build** en staging

4. **Verificar deployment en GKE**:
   ```bash
   kubectl get pods -n ecommerce-staging
   kubectl get svc -n ecommerce-staging
   ```

## ⚠️ Posibles Problemas

### Problema: junit plugin error
**Solución**: Ya aplicamos archiveArtifacts en dev, aplicar lo mismo en staging

### Problema: No puede pull imagen de dev
**Solución**: Asegurar que las imágenes de dev se suben al registry

### Problema: GKE authentication failed
**Solución**: Verificar que gcloud está autenticado en Jenkins

## 📝 Notas

- Staging usa el mismo Jenkins que dev
- Las imágenes se reutilizan de dev (pull y retag)
- E2E tests se ejecutan contra el servicio desplegado en GKE
- Performance tests usan Locust (necesita estar instalado)
