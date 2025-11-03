# Script para corregir la configuración de kubectl context en todos los Jenkinsfiles

$services = @(
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service",
    "shipping-service"
)

$oldConfig = @'
                        # Configurar KUBECONFIG explícitamente
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        
                        # Configurar servidor de Minikube
                        kubectl config set-cluster minikube --server=https://192.168.67.2:8443 --insecure-skip-tls-verify=true
                        
                        # Cambiar contexto a Minikube
                        kubectl config use-context minikube
'@

$newConfig = @'
                        # Configurar KUBECONFIG explícitamente
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        
                        # Configurar cluster de Minikube
                        kubectl config set-cluster minikube --server=https://192.168.67.2:8443 --insecure-skip-tls-verify=true
                        
                        # Configurar credenciales (sin autenticación para desarrollo local)
                        kubectl config set-credentials minikube-user --token=dummy
                        
                        # Crear contexto de Minikube
                        kubectl config set-context minikube --cluster=minikube --user=minikube-user
                        
                        # Cambiar al contexto de Minikube
                        kubectl config use-context minikube
'@

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Actualizando $jenkinsfile..."
        
        $content = Get-Content $jenkinsfile -Raw
        $content = $content -replace [regex]::Escape($oldConfig), $newConfig
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        
        Write-Host "✓ $jenkinsfile actualizado"
    } else {
        Write-Host "⚠ $jenkinsfile no encontrado"
    }
}

Write-Host "`n✓ Todos los Jenkinsfiles han sido actualizados con la configuración correcta de kubectl context"
