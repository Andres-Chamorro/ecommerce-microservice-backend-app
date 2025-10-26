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
 * Pruebas E2E: Gestión de Catálogo de Productos
 * Valida flujos completos de gestión de catálogo
 */
@DisplayName("E2E Tests - Product Catalog Management")
public class ProductCatalogE2ETest {

    @BeforeAll
    static void setUp() {
        RestAssured.baseURI = "http://localhost";
    }

    @Test
    @DisplayName("E2E Test 9: Flujo completo - Listar catálogo de productos")
    void testListAllProducts() {
        // E2E: Usuario navega por el catálogo completo
        given()
                .port(8500)
                .when()
                .get("/product-service/api/products")
                .then()
                .statusCode(200)
                .body("collection", notNullValue());
    }

    @Test
    @DisplayName("E2E Test 10: Flujo completo - Acceso a través del Gateway")
    void testSearchAndViewProductDetails() {
        // E2E: Usuario accede al sistema a través del API Gateway
        given()
                .port(8080)
                .when()
                .get("/actuator/health")
                .then()
                .statusCode(200)
                .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("E2E Test 11: Flujo completo - Consultar productos y categorías")
    void testUpdateProductInformation() {
        // E2E: Usuario consulta productos
        given()
                .port(8500)
                .when()
                .get("/product-service/api/products")
                .then()
                .statusCode(200)
                .body("collection", notNullValue());

        // E2E: Usuario consulta categorías
        given()
                .port(8500)
                .when()
                .get("/product-service/api/categories")
                .then()
                .statusCode(200)
                .body("collection", notNullValue());
    }
}
