package com.selimhorri.app.integration;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Aplicación de prueba para Integration Tests
 * Esta clase proporciona el contexto de Spring Boot necesario para las pruebas de integración
 */
@SpringBootApplication
public class IntegrationTestApplication {

    public static void main(String[] args) {
        SpringApplication.run(IntegrationTestApplication.class, args);
    }
}
