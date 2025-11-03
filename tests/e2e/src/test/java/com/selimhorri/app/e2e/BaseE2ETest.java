package com.selimhorri.app.e2e;

import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;

/**
 * Clase base para pruebas E2E
 * Configura las URLs base según el ambiente (local o staging)
 */
public abstract class BaseE2ETest {

    protected static String baseUrl;
    protected static int servicePort;
    
    @BeforeAll
    static void setUpBase() {
        // Leer URL del servicio desde system property (pasado por Jenkins)
        String serviceUrl = System.getProperty("service.url");
        
        if (serviceUrl != null && !serviceUrl.isEmpty()) {
            // Ambiente staging/CI - usar URL pasada por Jenkins
            baseUrl = serviceUrl.substring(0, serviceUrl.lastIndexOf(':'));
            String portStr = serviceUrl.substring(serviceUrl.lastIndexOf(':') + 1);
            servicePort = Integer.parseInt(portStr);
            
            RestAssured.baseURI = baseUrl;
            RestAssured.port = servicePort;
            
            System.out.println("✓ Configuración E2E: " + serviceUrl);
        } else {
            // Ambiente local - usar localhost
            baseUrl = "http://localhost";
            RestAssured.baseURI = baseUrl;
            
            System.out.println("✓ Configuración E2E: localhost (ambiente local)");
        }
    }
    
    /**
     * Obtiene la URL completa para un servicio específico
     */
    protected static String getServiceUrl(String serviceName, int defaultPort) {
        if (System.getProperty("service.url") != null) {
            // En staging, todos los servicios usan la misma IP externa pero diferentes puertos
            // Necesitamos obtener las IPs de cada servicio
            return baseUrl + ":" + servicePort;
        } else {
            // En local, cada servicio tiene su propio puerto
            return baseUrl + ":" + defaultPort;
        }
    }
}
