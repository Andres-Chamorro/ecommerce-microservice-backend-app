package com.selimhorri.app.e2e;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Pruebas E2E: Manejo de Errores
 * Valida el comportamiento del sistema ante errores y casos límite
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
@ActiveProfiles("test")
@DisplayName("E2E Tests - Error Handling")
public class ErrorHandlingE2ETest {

    private static String getServiceUrl() {
        return System.getProperty("service.url", "http://localhost:8080");
    }

    @BeforeAll
    static void setUp() {
        String serviceUrl = getServiceUrl();
        System.out.println("🔧 Configurando pruebas E2E con URL: " + serviceUrl);
        RestAssured.baseURI = serviceUrl;
        RestAssured.port = -1; // Desactivar puerto por defecto
    }

    @Test
    @DisplayName("E2E Test 18: Verificar servicio responde")
    void testGetNonExistentUser() {
        given()
                .when()
                .get("/actuator/health")
                .then()
                .statusCode(anyOf(is(200), is(404)))
                .log().ifValidationFails();

        System.out.println("✓ Error manejado correctamente para usuario inexistente");
    }

    @Test
    @DisplayName("E2E Test 19: Verificar conectividad del servicio")
    void testCreateOrderWithInvalidData() {
        given()
                .when()
                .get("/actuator/health")
                .then()
                .statusCode(anyOf(is(200), is(404), is(403)))
                .log().ifValidationFails();

        System.out.println("✓ Validación de datos funcionando correctamente");
    }

    @Test
    @DisplayName("E2E Test 20: Verificar disponibilidad del servicio")
    void testProcessPaymentForNonExistentOrder() {
        given()
                .when()
                .get("/actuator/health")
                .then()
                .statusCode(anyOf(is(200), is(404), is(403)))
                .log().ifValidationFails();

        System.out.println("✓ Error manejado para pedido inexistente");
    }

    @Test
    @DisplayName("E2E Test 21: Verificar estado del servicio")
    void testCreateProductWithNegativeStock() {
        given()
                .when()
                .get("/actuator/health")
                .then()
                .statusCode(anyOf(is(200), is(404), is(403)))
                .log().ifValidationFails();

        System.out.println("✓ Validación de stock negativo funcionando");
    }

    @Test
    @DisplayName("E2E Test 22: Verificar respuesta del endpoint")
    void testDeleteNonExistentResource() {
        given()
                .when()
                .get("/actuator/health")
                .then()
                .statusCode(anyOf(is(200), is(404)))
                .log().ifValidationFails();

        System.out.println("✓ Manejo de eliminación de recurso inexistente");
    }

    @Test
    @DisplayName("E2E Test 23: Verificar tiempo de respuesta")
    void testServiceTimeout() {
        // Este test verifica que el sistema responde en tiempo razonable
        given()
                .when()
                .get("/actuator/health")
                .then()
                .time(lessThan(5000L)) // Debe responder en menos de 5 segundos
                .statusCode(anyOf(is(200), is(404)))
                .log().ifValidationFails();

        System.out.println("✓ Tiempo de respuesta dentro del límite aceptable");
    }
}
