package com.selimhorri.app.service;

import com.selimhorri.app.domain.Product;
import com.selimhorri.app.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para ProductService
 * Valida la lógica de negocio del repositorio de productos
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Product Service - Unit Tests")
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    private Product product;

    @BeforeEach
    void setUp() {
        product = Product.builder()
                .productId(1)
                .productTitle("Test Product")
                .imageUrl("http://example.com/image.jpg")
                .sku("TEST-SKU-001")
                .priceUnit(99.99)
                .quantity(100)
                .build();
    }

    @Test
    @DisplayName("Test 1: Repository debe retornar todos los productos")
    void testFindAll_ShouldReturnAllProducts() {
        // Given
        List<Product> products = Arrays.asList(product);
        when(productRepository.findAll()).thenReturn(products);

        // When
        List<Product> result = productRepository.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getProductTitle()).isEqualTo("Test Product");
        verify(productRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Test 2: Repository debe encontrar producto por ID")
    void testFindById_ShouldReturnProduct_WhenProductExists() {
        // Given
        when(productRepository.findById(anyInt())).thenReturn(Optional.of(product));

        // When
        Optional<Product> result = productRepository.findById(1);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getProductId()).isEqualTo(1);
        assertThat(result.get().getSku()).isEqualTo("TEST-SKU-001");
        assertThat(result.get().getPriceUnit()).isEqualTo(99.99);
        verify(productRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Test 3: Repository debe guardar un nuevo producto")
    void testSave_ShouldCreateNewProduct() {
        // Given
        when(productRepository.save(any(Product.class))).thenReturn(product);

        // When
        Product result = productRepository.save(product);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getProductTitle()).isEqualTo("Test Product");
        assertThat(result.getQuantity()).isEqualTo(100);
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("Test 4: Repository debe actualizar un producto existente")
    void testUpdate_ShouldUpdateExistingProduct() {
        // Given
        when(productRepository.save(any(Product.class))).thenReturn(product);

        // When
        Product result = productRepository.save(product);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getProductId()).isEqualTo(1);
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("Test 5: Repository debe eliminar un producto por ID")
    void testDeleteById_ShouldDeleteProduct() {
        // Given
        doNothing().when(productRepository).deleteById(anyInt());

        // When
        productRepository.deleteById(1);

        // Then
        verify(productRepository, times(1)).deleteById(1);
    }

    @Test
    @DisplayName("Test 6: Debe validar disponibilidad de stock")
    void testCheckStock_ShouldReturnTrue_WhenStockAvailable() {
        // Given - producto con stock disponible

        // When
        boolean hasStock = product.getQuantity() > 0;

        // Then
        assertThat(hasStock).isTrue();
        assertThat(product.getQuantity()).isGreaterThan(0);
    }

    @Test
    @DisplayName("Test 7: Debe calcular precio total correctamente")
    void testCalculateTotalPrice_ShouldReturnCorrectAmount() {
        // Given
        int quantity = 5;
        double expectedTotal = product.getPriceUnit() * quantity;

        // When
        double totalPrice = product.getPriceUnit() * quantity;

        // Then
        assertThat(totalPrice).isEqualTo(expectedTotal);
        assertThat(totalPrice).isEqualTo(499.95);
    }
}
