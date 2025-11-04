# Solución: Minikube Kubelet no inicia automáticamente

## Problema
Después de reiniciar el contenedor de Minikube, Kubernetes no está disponible:
```
The connection to the server 192.168.67.2:8443 was refused
```

## Causa
Kubelet (el agente de Kubernetes) no está configurado para iniciarse automáticamente cuando Minikube se reinicia.

## Solución Aplicada

### 1. Iniciar Kubelet manualmente
```bash
docker exec minikube systemctl start kubelet
```

### 2. Habilitar inicio automático de Kubelet
```bash
docker exec minikube systemctl enable kubelet
```

### 3. Verificar que funciona
```bash
docker exec jenkins kubectl get nodes
docker exec jenkins kubectl cluster-info
```

## Resultado
✅ Kubelet ahora se inicia automáticamente cuando Minikube se reinicia
✅ Jenkins puede conectarse a Minikube correctamente
✅ Los pipelines de dev pueden desplegar en Minikube

## Verificación
```bash
# Ver estado de Kubelet
docker exec minikube systemctl status kubelet

# Ver nodos de Kubernetes
docker exec jenkins kubectl get nodes

# Ver info del cluster
docker exec jenkins kubectl cluster-info
```

## Arquitectura Final para DEV

```
Pipeline DEV (rama dev)
├── Build Maven
├── Unit Tests
├── Build Docker Image (local)
└── Deploy to Minikube (local)
    ├── No push a GCP registry
    ├── Imagen local en Minikube
    └── Despliegue rápido para desarrollo
```

## Notas
- Esta solución es solo para el ambiente DEV
- STAGING y MASTER usarán GCP y GKE (no Minikube)
- Minikube es solo para desarrollo local rápido
