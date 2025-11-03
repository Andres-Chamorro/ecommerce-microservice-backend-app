# Script para agregar JaCoCo plugin a todos los pom.xml de los microservicios

Write-Host "📊 Agregando plugin JaCoCo a todos los microservicios..." -ForegroundColor Cyan

$services = @(
    'user-service',
    'product-service',
    'order-service',
    'payment-service',
    'shipping-service',
    'favourite-service'
)

$jacocoPlugin = @'
			<plugin>
				<groupId>org.jacoco</groupId>
				<artifactId>jacoco-maven-plugin</artifactId>
				<version>0.8.8</version>
				<executions>
					<execution>
						<goals>
							<goal>prepare-agent</goal>
						</goals>
					</execution>
					<execution>
						<id>report</id>
						<phase>test</phase>
						<goals>
							<goal>report</goal>
						</goals>
					</execution>
				</executions>
			</plugin>
'@

foreach ($service in $services) {
    $pomPath = "$service/pom.xml"
    
    if (Test-Path $pomPath) {
        Write-Host "📝 Procesando $pomPath..." -ForegroundColor Yellow
        
        $content = Get-Content $pomPath -Raw
        
        # Verificar si JaCoCo ya está configurado
        if ($content -match 'jacoco-maven-plugin') {
            Write-Host "⚠️  JaCoCo ya está configurado en $pomPath" -ForegroundColor Yellow
            continue
        }
        
        # Buscar la sección de plugins y agregar JaCoCo
        if ($content -match '(<build>[\s\S]*?<plugins>)') {
            $content = $content -replace '(<build>[\s\S]*?<plugins>)', "`$1`n$jacocoPlugin"
            $content | Set-Content $pomPath -NoNewline
            Write-Host "✅ JaCoCo agregado a $pomPath" -ForegroundColor Green
        }
        else {
            Write-Host "⚠️  No se encontró sección <plugins> en $pomPath" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️  No se encontró $pomPath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Proceso completado" -ForegroundColor Green
Write-Host "Ahora los tests generarán reportes de cobertura en target/site/jacoco/" -ForegroundColor Cyan
