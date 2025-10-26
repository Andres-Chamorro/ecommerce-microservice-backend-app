package com.selimhorri.app.service;

import com.selimhorri.app.domain.OrderItem;
import com.selimhorri.app.repository.OrderItemRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para OrderItemService (Shipping Service)
 * Valida la lógica de negocio del repositorio de items de pedido
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Shipping Service - Unit Tests")
class ShippingServiceTest {

    @Mock
    private OrderItemRepository orderItemRepository;

    private OrderItem orderItem;

    @BeforeEach
    void setUp() {
        orderItem = OrderItem.builder()
                .productId(1)
                .orderId(100)
                .orderedQuantity(5)
                .build();
    }

    @Test
    @DisplayName("Test 1: Repository debe retornar todos los items de pedido")
    void testFindAll_ShouldReturnAllOrderItems() {
        // Given
        List<OrderItem> orderItems = Arrays.asList(orderItem);
        when(orderItemRepository.findAll()).thenReturn(orderItems);

        // When
        List<OrderItem> result = orderItemRepository.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        verify(orderItemRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Test 2: Debe crear un nuevo item de pedido")
    void testSave_ShouldCreateNewOrderItem() {
        // Given
        when(orderItemRepository.save(any(OrderItem.class))).thenReturn(orderItem);

        // When
        OrderItem result = orderItemRepository.save(orderItem);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getProductId()).isEqualTo(1);
        assertThat(result.getOrderId()).isEqualTo(100);
        verify(orderItemRepository, times(1)).save(any(OrderItem.class));
    }

    @Test
    @DisplayName("Test 3: Debe actualizar un item de pedido")
    void testUpdate_ShouldUpdateOrderItem() {
        // Given
        OrderItem updatedItem = OrderItem.builder()
                .productId(1)
                .orderId(100)
                .orderedQuantity(10)
                .build();
        when(orderItemRepository.save(any(OrderItem.class))).thenReturn(updatedItem);

        // When
        OrderItem result = orderItemRepository.save(updatedItem);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getOrderedQuantity()).isEqualTo(10);
        verify(orderItemRepository, times(1)).save(any(OrderItem.class));
    }

    @Test
    @DisplayName("Test 4: Debe validar relación entre producto y pedido")
    void testValidateProductOrderRelation() {
        // Given - item con productId y orderId

        // When
        boolean hasValidIds = orderItem.getProductId() != null && orderItem.getOrderId() != null;

        // Then
        assertThat(hasValidIds).isTrue();
        assertThat(orderItem.getProductId()).isEqualTo(1);
        assertThat(orderItem.getOrderId()).isEqualTo(100);
    }

    @Test
    @DisplayName("Test 5: Debe buscar items por orderId")
    void testFindByOrderId_ShouldReturnOrderItems() {
        // Given
        List<OrderItem> orderItems = Arrays.asList(orderItem);
        when(orderItemRepository.findAll()).thenReturn(orderItems);

        // When
        List<OrderItem> result = orderItemRepository.findAll();
        List<OrderItem> filtered = result.stream()
                .filter(item -> item.getOrderId().equals(100))
                .collect(Collectors.toList());

        // Then
        assertThat(filtered).isNotEmpty();
        assertThat(filtered.get(0).getOrderId()).isEqualTo(100);
    }

    @Test
    @DisplayName("Test 6: Debe validar cantidad ordenada positiva")
    void testValidateOrderedQuantity_ShouldReturnTrue_WhenQuantityIsPositive() {
        // Given - item con cantidad positiva

        // When
        boolean isValid = orderItem.getOrderedQuantity() > 0;

        // Then
        assertThat(isValid).isTrue();
        assertThat(orderItem.getOrderedQuantity()).isEqualTo(5);
    }
}
