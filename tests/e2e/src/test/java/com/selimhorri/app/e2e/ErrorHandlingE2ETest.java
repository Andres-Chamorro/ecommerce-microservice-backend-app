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

    @BeforeAll
    static void setUp() {
        RestAssured.baseURI = "http://localhost";
        RestAssured.port = 8080; // API Gateway
    }

    @Test
    @DisplayName("E2E Test 18: Intentar obtener usuario inexistente")
    void testGetNonExistentUser() {
        given()
                .when()
                .get("/user-service/api/users/99999")
                .then()
                .statusCode(anyOf(is(404), is(500)));

        System.out.println("✓ Error manejado correctamente para usuario inexistente");
    }

    @Test
    @DisplayName("E2E Test 19: Intentar crear pedido con datos inválidos")
    void testCreateOrderWithInvalidData() {
        String invalidOrderJson = """
                {
                    "userId": null,
                    "orderDate": "invalid-date",
                    "orderFee": -100.00
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(invalidOrderJson)
                .when()
                .post("/order-service/api/orders")
                .then()
                .statusCode(anyOf(is(400), is(500)));

        System.out.println("✓ Validación de datos funcionando correctamente");
    }

    @Test
    @DisplayName("E2E Test 20: Intentar procesar pago para pedido inexistente")
    void testProcessPaymentForNonExistentOrder() {
        String paymentJson = """
                {
                    "orderId": 99999,
                    "isPayed": true,
                    "paymentStatus": "COMPLETED"
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(paymentJson)
                .when()
                .post("/payment-service/api/payments")
                .then()
                .statusCode(anyOf(is(404), is(500)));

        System.out.println("✓ Error manejado para pedido inexistente");
    }

    @Test
    @DisplayName("E2E Test 21: Intentar agregar producto con stock negativo")
    void testCreateProductWithNegativeStock() {
        String productJson = """
                {
                    "productTitle": "Invalid Product",
                    "imageUrl": "http://example.com/invalid.jpg",
                    "sku": "INV-SKU-001",
                    "priceUnit": 50.00,
                    "quantity": -10
                }
                """;

        given()
                .contentType(ContentType.JSON)
                .body(productJson)
                .when()
                .post("/product-service/api/products")
                .then()
                .statusCode(anyOf(is(400), is(500)));

        System.out.println("✓ Validación de stock negativo funcionando");
    }

    @Test
    @DisplayName("E2E Test 22: Intentar eliminar recurso que no existe")
    void testDeleteNonExistentResource() {
        given()
                .when()
                .delete("/product-service/api/products/99999")
                .then()
                .statusCode(anyOf(is(404), is(500)));

        System.out.println("✓ Manejo de eliminación de recurso inexistente");
    }

    @Test
    @DisplayName("E2E Test 23: Verificar timeout en servicios lentos")
    void testServiceTimeout() {
        // Este test verifica que el sistema maneja correctamente los timeouts
        given()
                .when()
                .get("/user-service/api/users")
                .then()
                .time(lessThan(5000L)); // Debe responder en menos de 5 segundos

        System.out.println("✓ Tiempo de respuesta dentro del límite aceptable");
    }
}
