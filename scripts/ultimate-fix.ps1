# Solución definitiva: Jenkins ejecuta kubectl via docker exec en minikube
Write-Host "=== Solución Definitiva ===" -ForegroundColor Green

# Crear un script wrapper en Jenkins que ejecute kubectl en minikube
Write-Host "Creando wrapper de kubectl..." -ForegroundColor Yellow

$wrapperScript = @'
#!/bin/bash
# Wrapper que ejecuta kubectl dentro de minikube
docker exec minikube kubectl "$@"
'@

$wrapperScript | Out-File -FilePath "kubectl-wrapper.sh" -Encoding ASCII

# Copiar a Jenkins y hacerlo ejecutable
docker cp kubectl-wrapper.sh jenkins:/usr/local/bin/kubectl-minikube
docker exec jenkins chmod +x /usr/local/bin/kubectl-minikube

# Crear alias
docker exec jenkins sh -c "echo 'alias kubectl=/usr/local/bin/kubectl-minikube' >> /var/jenkins_home/.bashrc"

Remove-Item kubectl-wrapper.sh

# Probar
Write-Host "`nProbando kubectl..." -ForegroundColor Yellow
docker exec jenkins /usr/local/bin/kubectl-minikube get nodes

Write-Host "`n✓ Listo! Usa 'kubectl-minikube' o configura alias en Jenkinsfile" -ForegroundColor Green
