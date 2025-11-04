# Script para arreglar las URLs en las pruebas de integración
# Las pruebas deben usar las URLs de Kubernetes en lugar de localhost

$integrationTestsPath = "tests/integration/src/test/java/com/selimhorri/app/integration"

# Crear clase de configuración para las URLs
$configClass = @'
package com.selimhorri.app.integration;

/**
 * Configuración centralizada para las pruebas de integración
 * Lee las URLs desde variables de entorno o usa valores por defecto
 */
public class TestConfig {
    
    // URLs de servicios - se pueden configurar via variables de entorno
    public static final String USER_SERVICE_URL = getEnvOrDefault("USER_SERVICE_URL", "http://localhost:8700");
    public static final String ORDER_SERVICE_URL = getEnvOrDefault("ORDER_SERVICE_URL", "http://localhost:8300");
    public static final String PAYMENT_SERVICE_URL = getEnvOrDefault("PAYMENT_SERVICE_URL", "http://localhost:8400");
    public static final String PRODUCT_SERVICE_URL = getEnvOrDefault("PRODUCT_SERVICE_URL", "http://localhost:8500");
    public static final String SHIPPING_SERVICE_URL = getEnvOrDefault("SHIPPING_SERVICE_URL", "http://localhost:8600");
    public static final String FAVOURITE_SERVICE_URL = getEnvOrDefault("FAVOURITE_SERVICE_URL", "http://localhost:8800");
    
    private static String getEnvOrDefault(String envVar, String defaultValue) {
        String value = System.getenv(envVar);
        return (value != null && !value.isEmpty()) ? value : defaultValue;
    }
    
    // Extraer host y puerto de una URL
    public static String getHost(String url) {
        return url.replaceAll("http://", "").split(":")[0];
    }
    
    public static int getPort(String url) {
        String[] parts = url.replaceAll("http://", "").split(":");
        return parts.length > 1 ? Integer.parseInt(parts[1].split("/")[0]) : 80;
    }
}
'@

# Crear el archivo de configuración
$configPath = "$integrationTestsPath/TestConfig.java"
Write-Host "Creando clase de configuración en: $configPath"
New-Item -Path $configPath -ItemType File -Force | Out-Null
Set-Content -Path $configPath -Value $configClass -Encoding UTF8

Write-Host "✅ Clase TestConfig creada exitosamente"
Write-Host ""
Write-Host "Ahora las pruebas pueden usar:"
Write-Host "  - TestConfig.USER_SERVICE_URL"
Write-Host "  - TestConfig.ORDER_SERVICE_URL"
Write-Host "  - etc."
