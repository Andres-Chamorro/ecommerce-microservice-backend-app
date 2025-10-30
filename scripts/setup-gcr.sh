#!/bin/bash

# Script para configurar Google Container Registry (GCR)
# Este script habilita GCR y configura Docker para usarlo

set -e

echo "🚀 Configurando Google Container Registry (GCR)..."

# Cargar variables de entorno
source .env.gcp

echo "📋 Configuración:"
echo "  PROJECT_ID: $PROJECT_ID"
echo "  REGION: $REGION"
echo "  REGISTRY: $REGISTRY"

# 1. Habilitar Artifact Registry API
echo ""
echo "1️⃣ Habilitando Artifact Registry API..."
gcloud services enable artifactregistry.googleapis.com --project=$PROJECT_ID

# 2. Verificar si el repositorio ya existe
echo ""
echo "2️⃣ Verificando repositorio..."
if gcloud artifacts repositories describe ecommerce-registry \
    --location=$REGION \
    --project=$PROJECT_ID &>/dev/null; then
    echo "✅ Repositorio 'ecommerce-registry' ya existe"
else
    echo "📦 Creando repositorio 'ecommerce-registry'..."
    gcloud artifacts repositories create ecommerce-registry \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker registry para microservicios de ecommerce" \
        --project=$PROJECT_ID
    echo "✅ Repositorio creado exitosamente"
fi

# 3. Configurar autenticación de Docker con GCR
echo ""
echo "3️⃣ Configurando autenticación de Docker..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# 4. Verificar que Jenkins puede acceder
echo ""
echo "4️⃣ Verificando permisos de Jenkins..."
if [ -f jenkins-gcp-key.json ]; then
    echo "✅ Service account key encontrada: jenkins-gcp-key.json"
    
    # Activar service account
    gcloud auth activate-service-account --key-file=jenkins-gcp-key.json
    
    # Verificar permisos
    echo "Verificando permisos del service account..."
    gcloud projects get-iam-policy $PROJECT_ID \
        --flatten="bindings[].members" \
        --filter="bindings.members:serviceAccount" \
        --format="table(bindings.role)" | head -10
else
    echo "⚠️  WARNING: No se encontró jenkins-gcp-key.json"
    echo "   Jenkins necesitará este archivo para autenticarse"
fi

# 5. Mostrar información del registry
echo ""
echo "5️⃣ Información del Registry:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Registry URL: $REGISTRY"
echo ""
echo "Ejemplo de uso:"
echo "  docker tag mi-imagen:latest $REGISTRY/mi-imagen:latest"
echo "  docker push $REGISTRY/mi-imagen:latest"
echo "  docker pull $REGISTRY/mi-imagen:latest"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 6. Probar el registry con una imagen de prueba
echo ""
echo "6️⃣ Probando el registry..."
echo "Descargando imagen de prueba..."
docker pull hello-world:latest

echo "Etiquetando imagen..."
docker tag hello-world:latest $REGISTRY/hello-world:test

echo "Subiendo imagen al registry..."
if docker push $REGISTRY/hello-world:test; then
    echo "✅ Registry funcionando correctamente"
    
    echo ""
    echo "Limpiando imagen de prueba..."
    gcloud artifacts docker images delete $REGISTRY/hello-world:test --quiet || true
else
    echo "❌ Error al subir imagen al registry"
    exit 1
fi

echo ""
echo "✅ =========================================="
echo "✅ Google Container Registry configurado"
echo "✅ =========================================="
echo ""
echo "📝 Próximos pasos:"
echo "  1. Actualizar Jenkinsfiles con: $REGISTRY"
echo "  2. Configurar Jenkins para usar jenkins-gcp-key.json"
echo "  3. Probar un pipeline"
echo ""
