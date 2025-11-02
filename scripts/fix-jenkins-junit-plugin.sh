#!/bin/bash
# Script para actualizar el plugin JUnit y sus dependencias en Jenkins

echo "Actualizando plugins de Jenkins para resolver NoClassDefFoundError..."

# Obtener el contenedor de Jenkins
JENKINS_CONTAINER=$(docker ps --filter "name=jenkins" --format "{{.Names}}" | head -n 1)

if [ -z "$JENKINS_CONTAINER" ]; then
    echo "Error: No se encontró el contenedor de Jenkins"
    exit 1
fi

echo "Contenedor Jenkins encontrado: $JENKINS_CONTAINER"

# Instalar/actualizar plugins necesarios
echo "Instalando/actualizando plugins..."

docker exec -u root $JENKINS_CONTAINER jenkins-plugin-cli --plugins \
    junit:latest \
    workflow-api:latest \
    workflow-step-api:latest \
    workflow-support:latest \
    workflow-cps:latest \
    workflow-job:latest \
    workflow-basic-steps:latest \
    workflow-durable-task-step:latest \
    jacoco:latest \
    structs:latest \
    plugin-util-api:latest

echo ""
echo "Plugins actualizados. Reiniciando Jenkins..."

# Reiniciar Jenkins de forma segura
docker exec $JENKINS_CONTAINER java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080/ safe-restart || \
docker restart $JENKINS_CONTAINER

echo ""
echo "✓ Jenkins reiniciado"
echo "Espera unos minutos para que Jenkins termine de iniciar"
echo "Luego vuelve a ejecutar el pipeline"
