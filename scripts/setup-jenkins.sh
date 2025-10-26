#!/bin/bash

# Script para configurar Jenkins con todos los requisitos

echo "🚀 Configurando Jenkins para el proyecto..."

# Paso 1: Levantar Jenkins
echo "📦 Levantando Jenkins con Docker Compose..."
docker-compose -f docker-compose.jenkins.yml up -d

echo "⏳ Esperando a que Jenkins inicie (esto puede tomar 1-2 minutos)..."
sleep 60

# Paso 2: Obtener la contraseña inicial
echo ""
echo "🔑 Contraseña inicial de Jenkins:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo ""
echo "✅ Jenkins está corriendo en: http://localhost:8079"
echo ""
echo "📋 Próximos pasos:"
echo "1. Abre http://localhost:8079 en tu navegador"
echo "2. Usa la contraseña mostrada arriba"
echo "3. Selecciona 'Install suggested plugins'"
echo "4. Crea un usuario admin"
echo "5. Instala plugins adicionales:"
echo "   - Docker Pipeline"
echo "   - Kubernetes"
echo "   - GitHub"
echo "   - Pipeline"
echo "   - Git"
echo ""
echo "6. Configura las credenciales:"
echo "   - Docker Hub (ID: docker-hub-credentials)"
echo "   - GitHub Token (ID: github-token)"
echo "   - Kubeconfig (ID: kubeconfig)"
echo ""
echo "7. Crea un nuevo Pipeline Job apuntando a tu repositorio"
