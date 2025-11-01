# Reiniciar Jenkins

## Opción 1: Desde la UI (Recomendado)
1. Ve a: http://localhost:8080/restart
2. Click en "Yes"
3. Espera 1-2 minutos

## Opción 2: Desde Docker
```powershell
docker restart jenkins
```

## Después del reinicio
1. Ve a cada servicio multibranch
2. Click en "Scan Multibranch Pipeline Now"
3. Deberían ejecutarse todos los pipelines
