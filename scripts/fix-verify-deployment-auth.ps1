# Script para agregar configuración de kubectl en stage Verify Deployment

$services = @("user-service", "product-service", "order-service", "payment-service", "shipping-service", "favourite-service")

$kubectlConfig = @'
                        # Configurar kubectl para Minikube
                        export KUBECONFIG=/var/jenkins_home/.kube/config
                        kubectl config set-cluster minikube --server=https://192.168.67.2:8443 --insecure-skip-tls-verify=true
                        kubectl config use-context minikube
                        
'@

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "Procesando $jenkinsfile..." -ForegroundColor Cyan
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Buscar el patrón en Verify Deployment y agregar configuración de kubectl
        $pattern = '                    sh """'
        $replacement = "                    sh ```"`"`n$kubectlConfig"
        
        # Solo reemplazar en el contexto de Verify Deployment
        if ($content -match "stage\('Verify Deployment'\)") {
            # Encontrar la posición del stage Verify Deployment
            $verifyStart = $content.IndexOf("stage('Verify Deployment')")
            $verifySection = $content.Substring($verifyStart, 1000)
            
            if ($verifySection -match 'sh """' -and $verifySection -notmatch 'export KUBECONFIG') {
                # Necesita el fix
                $oldPattern = 'stage\(''Verify Deployment''\)[\s\S]*?sh """'
                $newPattern = $oldPattern -replace 'sh """', "sh ```"`"`n$kubectlConfig"
                
                Write-Host "Needs fix in $jenkinsfile" -ForegroundColor Yellow
            } else {
                Write-Host "Already fixed or different format in $jenkinsfile" -ForegroundColor Green
            }
        }
    }
}

Write-Host "`nScript completed" -ForegroundColor Green
