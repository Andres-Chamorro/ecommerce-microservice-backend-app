# Instalar Pipeline Stage View en Jenkins

## Problema
No aparece la visualización de stages (línea temporal) en los pipelines.

## Solución: Instalar el Plugin

### Paso 1: Ir a Manage Plugins

1. **Abrir Jenkins** en tu navegador: `http://localhost:8080`
2. Click en **"Manage Jenkins"** (menú lateral izquierdo)
3. Click en **"Plugins"** o **"Manage Plugins"**

### Paso 2: Buscar e Instalar el Plugin

1. Click en la pestaña **"Available plugins"**
2. En el buscador, escribe: **"Pipeline: Stage View"**
3. Marca la casilla del plugin: **"Pipeline: Stage View Plugin"**
4. Click en **"Install"** (o "Download now and install after restart")
5. Espera a que se instale

### Paso 3: Reiniciar Jenkins (si es necesario)

Si el plugin requiere reinicio:
```powershell
docker restart jenkins
```

O desde Jenkins:
- Marca la opción "Restart Jenkins when installation is complete and no jobs are running"

### Paso 4: Verificar

1. Ir a cualquier pipeline (ej: `user-service-pipeline`)
2. Click en el branch `staging`
3. Click en un build (ej: `#1`)
4. Deberías ver la **Stage View** con los stages en forma de cajas

## 🎨 Plugins Recomendados para Mejor Visualización

Además del Stage View, puedes instalar:

### 1. Pipeline: Stage View Plugin
- **Nombre**: `Pipeline: Stage View Plugin`
- **Descripción**: Muestra los stages como cajas con tiempos

### 2. Blue Ocean (Opcional - Vista Moderna)
- **Nombre**: `Blue Ocean`
- **Descripción**: Interfaz moderna y visual para pipelines
- **Acceso**: Click en "Open Blue Ocean" en el menú lateral

### 3. Pipeline Graph View (Alternativa)
- **Nombre**: `Pipeline Graph View Plugin`
- **Descripción**: Vista de grafo del pipeline

## 📸 Cómo se ve la Stage View

Después de instalar, verás algo así:

```
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Checkout   │Build Service │ Unit Tests   │Build Docker  │Deploy to K8s │Integration   │
│      ✅      │      ✅      │      ✅      │      ✅      │      ✅      │Tests ✅      │
│    2.5s      │    45.3s     │    12.1s     │    30.2s     │    25.8s     │    8.2s      │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

Con colores:
- 🟢 Verde = Éxito
- 🔴 Rojo = Fallo
- 🔵 Azul = En progreso
- ⚪ Gris = No ejecutado

## 🚨 Troubleshooting

### No aparece después de instalar
1. Refresca la página (F5)
2. Reinicia Jenkins: `docker restart jenkins`
3. Verifica que el plugin esté activo en "Installed plugins"

### Aparece pero está vacío
- Ejecuta el pipeline al menos una vez
- La vista solo aparece después de que el pipeline se ejecuta

### Quiero la vista de Blue Ocean
1. Instalar plugin "Blue Ocean"
2. Click en "Open Blue Ocean" en el menú
3. O ir a: `http://localhost:8080/blue`

## ✅ Verificación Rápida

Para verificar si tienes el plugin instalado:
1. Manage Jenkins → Plugins → Installed plugins
2. Buscar: "Pipeline: Stage View"
3. Si aparece, está instalado
4. Si no aparece, instalarlo desde "Available plugins"
