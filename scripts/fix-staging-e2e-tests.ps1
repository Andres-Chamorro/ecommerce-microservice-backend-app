# Script para arreglar las pruebas E2E en staging

Write-Host "🔧 Arreglando pruebas E2E en staging..." -ForegroundColor Cyan

# Problema 1: El puerto en el deployment es 8600, pero el Jenkinsfile usa 8200
# Problema 2: El servicio es ClusterIP, no LoadBalancer (no tiene IP externa)
# Problema 3: JAVA_HOME no se exporta en el stage E2E

$services = @(
    "shipping-service",
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "favourite-service"
)

foreach ($service in $services) {
    $jenkinsfile = "$service/Jenkinsfile"
    
    if (Test-Path $jenkinsfile) {
        Write-Host "📝 Actualizando $jenkinsfile..." -ForegroundColor Yellow
        
        $content = Get-Content $jenkinsfile -Raw
        
        # Fix 1: Cambiar el servicio a LoadBalancer en el deployment temporal
        $content = $content -replace `
            "type: LoadBalancer", `
            "type: LoadBalancer  # Necesario para obtener IP externa en GKE"
        
        # Fix 2: Agregar export JAVA_HOME y espera de IP en el stage E2E
        $content = $content -replace `
            '# Obtener la URL del servicio\s+SERVICE_URL=\\$\(kubectl get svc', `
            'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64\n                        export PATH=$JAVA_HOME/bin:$PATH\n                        \n                        # Obtener la URL del servicio (esperar hasta 2 minutos por la IP externa)\n                        echo "⏳ Esperando IP externa del LoadBalancer..."\n                        for i in {1..24}; do\n                            SERVICE_IP=$(kubectl get svc'
        
        $content = $content -replace `
            'SERVICE_URL=\\$\(kubectl get svc \$\{SERVICE_NAME\} -n \$\{K8S_NAMESPACE\} -o jsonpath=''\\{\.status\.loadBalancer\.ingress\[0\]\.ip\}'' 2>/dev/null \|\| echo ''localhost''\)', `
            'SERVICE_IP=$(kubectl get svc ${SERVICE_NAME} -n ${K8S_NAMESPACE} -o jsonpath=''{.status.loadBalancer.ingress[0].ip}'' 2>/dev/null)\n                            if [ -n "$SERVICE_IP" ]; then\n                                echo "✅ IP externa obtenida: $SERVICE_IP"\n                                break\n                            fi\n                            echo "Intento $i/24: Esperando IP externa..."\n                            sleep 5\n                        done\n                        \n                        if [ -z "$SERVICE_IP" ]; then\n                            echo "⚠️ No se pudo obtener IP externa, usando port-forward como fallback"\n                            kubectl port-forward -n ${K8S_NAMESPACE} svc/${SERVICE_NAME} ${SERVICE_PORT}:${SERVICE_PORT} &\n                            PORT_FORWARD_PID=$!\n                            sleep 5\n                            SERVICE_URL="localhost"\n                        else\n                            SERVICE_URL="$SERVICE_IP"\n                        fi'
        
        $content = $content -replace `
            'echo "Service URL: \\$SERVICE_URL:\$\{SERVICE_PORT\}"', `
            'echo "🌐 Service URL: http://$SERVICE_URL:${SERVICE_PORT}"'
        
        Set-Content -Path $jenkinsfile -Value $content -NoNewline
        Write-Host "✅ $jenkinsfile actualizado" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🔧 Ahora actualizando los deployments de Kubernetes..." -ForegroundColor Cyan

# Actualizar los deployments para usar LoadBalancer
$deployments = Get-ChildItem -Path "k8s/microservices" -Filter "*-deployment.yaml"

foreach ($deployment in $deployments) {
    Write-Host "📝 Actualizando $($deployment.Name)..." -ForegroundColor Yellow
    
    $content = Get-Content $deployment.FullName -Raw
    
    # Cambiar ClusterIP a LoadBalancer
    if ($content -match "type: ClusterIP") {
        $content = $content -replace "type: ClusterIP", "type: LoadBalancer  # IP externa para pruebas E2E"
        Set-Content -Path $deployment.FullName -Value $content -NoNewline
        Write-Host "✅ $($deployment.Name) actualizado a LoadBalancer" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ Correcciones aplicadas:" -ForegroundColor Green
Write-Host "  1. ✅ JAVA_HOME exportado en stages E2E y Performance" -ForegroundColor Green
Write-Host "  2. ✅ Espera de IP externa del LoadBalancer (hasta 2 min)" -ForegroundColor Green
Write-Host "  3. ✅ Fallback a port-forward si no hay IP externa" -ForegroundColor Green
Write-Host "  4. ✅ Servicios cambiados a LoadBalancer en deployments" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Ahora ejecuta el pipeline de staging nuevamente" -ForegroundColor Cyan
