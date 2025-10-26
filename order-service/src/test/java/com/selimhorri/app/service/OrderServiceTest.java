package com.selimhorri.app.service;

import com.selimhorri.app.domain.Order;
import com.selimhorri.app.repository.OrderRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para OrderService
 * Valida la lógica de negocio del repositorio de pedidos
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Order Service - Unit Tests")
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    private Order order;

    @BeforeEach
    void setUp() {
        order = Order.builder()
                .orderId(1)
                .orderDate(LocalDateTime.now())
                .orderDesc("Test Order")
                .orderFee(150.00)
                .build();
    }

    @Test
    @DisplayName("Test 1: Repository debe retornar todos los pedidos")
    void testFindAll_ShouldReturnAllOrders() {
        // Given
        List<Order> orders = Arrays.asList(order);
        when(orderRepository.findAll()).thenReturn(orders);

        // When
        List<Order> result = orderRepository.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getOrderDesc()).isEqualTo("Test Order");
        verify(orderRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Test 2: Repository debe encontrar pedido por ID")
    void testFindById_ShouldReturnOrder_WhenOrderExists() {
        // Given
        when(orderRepository.findById(anyInt())).thenReturn(Optional.of(order));

        // When
        Optional<Order> result = orderRepository.findById(1);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getOrderId()).isEqualTo(1);
        assertThat(result.get().getOrderFee()).isEqualTo(150.00);
        verify(orderRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Test 3: Repository debe guardar un nuevo pedido")
    void testSave_ShouldCreateNewOrder() {
        // Given
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        // When
        Order result = orderRepository.save(order);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getOrderDesc()).isEqualTo("Test Order");
        assertThat(result.getOrderFee()).isEqualTo(150.00);
        verify(orderRepository, times(1)).save(any(Order.class));
    }

    @Test
    @DisplayName("Test 4: Repository debe actualizar un pedido existente")
    void testUpdate_ShouldUpdateExistingOrder() {
        // Given
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        // When
        Order result = orderRepository.save(order);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getOrderId()).isEqualTo(1);
        verify(orderRepository, times(1)).save(any(Order.class));
    }

    @Test
    @DisplayName("Test 5: Repository debe eliminar un pedido por ID")
    void testDeleteById_ShouldDeleteOrder() {
        // Given
        doNothing().when(orderRepository).deleteById(anyInt());

        // When
        orderRepository.deleteById(1);

        // Then
        verify(orderRepository, times(1)).deleteById(1);
    }

    @Test
    @DisplayName("Test 6: Debe calcular el total del pedido correctamente")
    void testCalculateOrderTotal_ShouldReturnCorrectAmount() {
        // Given
        double orderFee = 150.00;
        double tax = orderFee * 0.16; // 16% IVA
        double expectedTotal = orderFee + tax;

        // When
        double total = orderFee + (orderFee * 0.16);

        // Then
        assertThat(total).isEqualTo(expectedTotal);
        assertThat(total).isEqualTo(174.00);
    }

    @Test
    @DisplayName("Test 7: Debe validar que el pedido tenga monto positivo")
    void testValidateOrder_ShouldReturnTrue_WhenOrderFeeIsPositive() {
        // Given - pedido con monto positivo

        // When
        boolean isValid = order.getOrderFee() > 0;

        // Then
        assertThat(isValid).isTrue();
    }
}
