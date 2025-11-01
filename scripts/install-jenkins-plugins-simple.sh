#!/bin/bash
# Script para instalar plugins de Jenkins

echo "📦 Instalando plugins de Jenkins..."

# Lista de plugins necesarios
PLUGINS=(
    "jacoco:latest"
    "htmlpublisher:latest"
    "junit:latest"
    "workflow-aggregator:latest"
    "git:latest"
    "docker-workflow:latest"
    "kubernetes:latest"
    "kubernetes-cli:latest"
)

echo ""
echo "Plugins a instalar:"
for plugin in "${PLUGINS[@]}"; do
    echo "  - $plugin"
done

echo ""
echo "Instalando plugins en Jenkins..."

# Copiar script de instalación al contenedor
docker exec jenkins bash -c "
cd /var/jenkins_home/plugins

# Instalar cada plugin
for plugin in jacoco htmlpublisher junit workflow-aggregator git docker-workflow kubernetes kubernetes-cli; do
    echo \"Descargando \$plugin...\"
    curl -L -o \${plugin}.hpi https://updates.jenkins.io/latest/\${plugin}.hpi 2>/dev/null || echo \"Error descargando \$plugin\"
done

echo \"Plugins descargados\"
"

echo ""
echo "✅ Plugins instalados"
echo "⚠️  Reiniciando Jenkins para activar plugins..."

# Reiniciar Jenkins
docker restart jenkins

echo ""
echo "Esperando a que Jenkins reinicie (60 segundos)..."
sleep 60

echo ""
echo "✅ Jenkins reiniciado"
echo "🌐 Accede a Jenkins en: http://localhost:8079"
echo ""
echo "Verifica que los plugins estén instalados en:"
echo "  Manage Jenkins > Manage Plugins > Installed"
