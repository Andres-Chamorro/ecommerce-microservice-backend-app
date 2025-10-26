package com.selimhorri.app.e2e;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Aplicación de prueba para E2E Tests
 * Esta clase proporciona el contexto de Spring Boot necesario para las pruebas end-to-end
 */
@SpringBootApplication
public class E2ETestApplication {

    public static void main(String[] args) {
        SpringApplication.run(E2ETestApplication.class, args);
    }
}
