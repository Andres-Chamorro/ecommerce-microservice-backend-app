Write-Host "Haciendo commit de los cambios de Jenkins..." -ForegroundColor Cyan

# Agregar archivos al staging
Write-Host "`nAgregando archivos modificados..." -ForegroundColor Yellow

git add jenkins/Dockerfile
git add docker-compose.jenkins.yml
git add */Jenkinsfile
git add */Jenkinsfile.dev
git add scripts/*.ps1
git add *.md

# Hacer commit
Write-Host "`nHaciendo commit..." -ForegroundColor Yellow

$commitMessage = @"
fix: Configurar Maven y kubectl en Jenkins para pipelines

- Crear imagen Docker personalizada de Jenkins con Maven, Docker CLI y kubectl
- Actualizar Jenkinsfiles para usar 'docker exec minikube kubectl'
- Copiar Jenkinsfile.dev a Jenkinsfile en todos los servicios
- Agregar documentacion completa de la solucion

Cambios principales:
- jenkins/Dockerfile: Imagen con todas las herramientas necesarias
- docker-compose.jenkins.yml: Usar imagen personalizada
- */Jenkinsfile: Pipelines actualizados para DEV con Minikube
- Scripts de automatizacion para deployment y configuracion

Resuelve:
- Error 'mvn: not found' en pipelines
- Error de conexion kubectl a Minikube
- Configuracion de deployments en Kubernetes local
"@

git commit -m $commitMessage

Write-Host "`nCommit realizado exitosamente" -ForegroundColor Green
Write-Host "`nPara subir los cambios ejecuta:" -ForegroundColor Cyan
Write-Host "  git push origin dev" -ForegroundColor White
