#!/bin/bash

# Script de diagnóstico para el pipeline de Jenkins
echo "🔍 Diagnóstico del Pipeline de Jenkins"
echo "===================================="

# Información del sistema
echo ""
echo "📋 Información del Sistema:"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
echo "Kernel: $(uname -r)"
echo "Arquitectura: $(uname -m)"

# Variables de entorno importantes
echo ""
echo "🌍 Variables de Entorno:"
echo "JAVA_HOME: ${JAVA_HOME:-'No definido'}"
echo "PATH: $PATH"
echo "GCP_PROJECT_ID: ${GCP_PROJECT_ID:-'No definido'}"
echo "USE_GKE_GCLOUD_AUTH_PLUGIN: ${USE_GKE_GCLOUD_AUTH_PLUGIN:-'No definido'}"

# Verificar herramientas instaladas
echo ""
echo "🔧 Herramientas Instaladas:"

# Java
if command -v java &> /dev/null; then
    echo "✅ Java: $(java -version 2>&1 | head -n 1)"
else
    echo "❌ Java: No instalado"
fi

# Maven
if command -v mvn &> /dev/null; then
    echo "✅ Maven: $(mvn --version | head -n 1)"
else
    echo "❌ Maven: No instalado"
fi

# Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
    echo "   Docker daemon status: $(systemctl is-active docker 2>/dev/null || echo 'No disponible')"
else
    echo "❌ Docker: No instalado"
fi

# kubectl
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>&1 | head -n 1)"
else
    echo "❌ kubectl: No instalado"
fi

# gcloud
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud: $(gcloud version --format='value(Google Cloud SDK)' 2>/dev/null || echo 'Instalado pero con errores')"
    
    # Verificar autenticación
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q "@"; then
        echo "   ✅ Autenticado con: $(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)"
        echo "   Proyecto actual: $(gcloud config get-value project 2>/dev/null || echo 'No configurado')"
    else
        echo "   ❌ No autenticado con GCP"
    fi
else
    echo "❌ gcloud: No instalado"
fi

# Verificar conectividad de red
echo ""
echo "🌐 Conectividad de Red:"
if curl -s --connect-timeout 5 https://google.com > /dev/null; then
    echo "✅ Conectividad a Internet: OK"
else
    echo "❌ Conectividad a Internet: FALLO"
fi

if curl -s --connect-timeout 5 https://registry-1.docker.io > /dev/null; then
    echo "✅ Conectividad a Docker Hub: OK"
else
    echo "❌ Conectividad a Docker Hub: FALLO"
fi

# Verificar permisos
echo ""
echo "🔐 Permisos:"
echo "Usuario actual: $(whoami)"
echo "Grupos: $(groups)"

if [ -w /var/run/docker.sock ]; then
    echo "✅ Permisos Docker: OK"
else
    echo "❌ Permisos Docker: Sin acceso a /var/run/docker.sock"
fi

# Verificar espacio en disco
echo ""
echo "💾 Espacio en Disco:"
df -h / | tail -n 1 | awk '{print "Raíz: " $4 " disponible de " $2 " (" $5 " usado)"}'
df -h /tmp 2>/dev/null | tail -n 1 | awk '{print "Temp: " $4 " disponible de " $2 " (" $5 " usado)")' || echo "Temp: Usando raíz"

# Verificar memoria
echo ""
echo "🧠 Memoria:"
free -h | grep "Mem:" | awk '{print "RAM: " $7 " disponible de " $2}'

echo ""
echo "🏁 Diagnóstico completado"
echo "Si hay errores ❌, deben resolverse antes de ejecutar el pipeline"