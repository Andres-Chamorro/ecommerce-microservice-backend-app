package com.selimhorri.app.resource;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.service.ProductService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Pruebas Unitarias para ProductResource (Controller)
 * Valida los endpoints REST del controlador de productos
 */
@WebMvcTest(ProductResource.class)
@DisplayName("Product Resource - Controller Unit Tests")
class ProductResourceTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ProductService productService;

    private ProductDto productDto;

    @BeforeEach
    void setUp() {
        productDto = ProductDto.builder()
                .productId(1)
                .productTitle("Test Product")
                .imageUrl("http://example.com/image.jpg")
                .sku("TEST-SKU-001")
                .priceUnit(99.99)
                .quantity(100)
                .build();
    }

    @Test
    @DisplayName("Test 1: GET /api/products - Debe retornar lista de productos")
    void testFindAll_ShouldReturnProductsList() throws Exception {
        // Given
        List<ProductDto> products = Arrays.asList(productDto);
        when(productService.findAll()).thenReturn(products);

        // When & Then
        mockMvc.perform(get("/api/products")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.collection", hasSize(1)))
                .andExpect(jsonPath("$.collection[0].productTitle", is("Test Product")))
                .andExpect(jsonPath("$.collection[0].priceUnit", is(99.99)));
    }

    @Test
    @DisplayName("Test 2: GET /api/products/{id} - Debe retornar producto por ID")
    void testFindById_ShouldReturnProduct() throws Exception {
        // Given
        when(productService.findById(anyInt())).thenReturn(productDto);

        // When & Then
        mockMvc.perform(get("/api/products/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.productId", is(1)))
                .andExpect(jsonPath("$.productTitle", is("Test Product")))
                .andExpect(jsonPath("$.sku", is("TEST-SKU-001")));
    }

    @Test
    @DisplayName("Test 3: POST /api/products - Debe crear un nuevo producto")
    void testSave_ShouldCreateNewProduct() throws Exception {
        // Given
        when(productService.save(any(ProductDto.class))).thenReturn(productDto);

        // When & Then
        mockMvc.perform(post("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(productDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.productId", is(1)))
                .andExpect(jsonPath("$.productTitle", is("Test Product")));
    }

    @Test
    @DisplayName("Test 4: PUT /api/products - Debe actualizar un producto")
    void testUpdate_ShouldUpdateProduct() throws Exception {
        // Given
        ProductDto updatedProduct = ProductDto.builder()
                .productId(1)
                .productTitle("Updated Product")
                .imageUrl("http://example.com/updated.jpg")
                .sku("UPD-SKU-001")
                .priceUnit(149.99)
                .quantity(50)
                .build();

        when(productService.update(any(ProductDto.class))).thenReturn(updatedProduct);

        // When & Then
        mockMvc.perform(put("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updatedProduct)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.productTitle", is("Updated Product")))
                .andExpect(jsonPath("$.priceUnit", is(149.99)));
    }

    @Test
    @DisplayName("Test 5: DELETE /api/products/{id} - Debe eliminar un producto")
    void testDeleteById_ShouldDeleteProduct() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/products/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("true"));
    }

    @Test
    @DisplayName("Test 6: GET /api/products - Debe retornar lista vacía cuando no hay productos")
    void testFindAll_ShouldReturnEmptyList_WhenNoProducts() throws Exception {
        // Given
        when(productService.findAll()).thenReturn(Arrays.asList());

        // When & Then
        mockMvc.perform(get("/api/products")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.collection", hasSize(0)));
    }
}
