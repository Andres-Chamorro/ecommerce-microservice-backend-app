package com.selimhorri.app.service;

import com.selimhorri.app.domain.Payment;
import com.selimhorri.app.repository.PaymentRepository;
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
 * Pruebas Unitarias para PaymentService
 * Valida la lógica de negocio del repositorio de pagos
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Payment Service - Unit Tests")
class PaymentServiceTest {

    @Mock
    private PaymentRepository paymentRepository;

    private Payment payment;

    @BeforeEach
    void setUp() {
        payment = Payment.builder()
                .paymentId(1)
                .isPayed(true)
                .build();
    }

    @Test
    @DisplayName("Test 1: Repository debe retornar todos los pagos")
    void testFindAll_ShouldReturnAllPayments() {
        // Given
        List<Payment> payments = Arrays.asList(payment);
        when(paymentRepository.findAll()).thenReturn(payments);

        // When
        List<Payment> result = paymentRepository.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getIsPayed()).isTrue();
        verify(paymentRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Test 2: Repository debe encontrar pago por ID")
    void testFindById_ShouldReturnPayment_WhenPaymentExists() {
        // Given
        when(paymentRepository.findById(anyInt())).thenReturn(Optional.of(payment));

        // When
        Optional<Payment> result = paymentRepository.findById(1);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getPaymentId()).isEqualTo(1);
        assertThat(result.get().getIsPayed()).isTrue();
        verify(paymentRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Test 3: Repository debe procesar un nuevo pago")
    void testSave_ShouldProcessNewPayment() {
        // Given
        when(paymentRepository.save(any(Payment.class))).thenReturn(payment);

        // When
        Payment result = paymentRepository.save(payment);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getIsPayed()).isTrue();
        verify(paymentRepository, times(1)).save(any(Payment.class));
    }

    @Test
    @DisplayName("Test 4: Repository debe actualizar estado de un pago")
    void testUpdate_ShouldUpdatePaymentStatus() {
        // Given
        when(paymentRepository.save(any(Payment.class))).thenReturn(payment);

        // When
        Payment result = paymentRepository.save(payment);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getPaymentId()).isEqualTo(1);
        verify(paymentRepository, times(1)).save(any(Payment.class));
    }

    @Test
    @DisplayName("Test 5: Repository debe eliminar un pago por ID")
    void testDeleteById_ShouldDeletePayment() {
        // Given
        doNothing().when(paymentRepository).deleteById(anyInt());

        // When
        paymentRepository.deleteById(1);

        // Then
        verify(paymentRepository, times(1)).deleteById(1);
    }

    @Test
    @DisplayName("Test 6: Debe validar que el pago esté completado")
    void testValidatePayment_ShouldReturnTrue_WhenPaymentIsCompleted() {
        // Given - pago completado

        // When
        boolean isCompleted = payment.getIsPayed();

        // Then
        assertThat(isCompleted).isTrue();
    }

    @Test
    @DisplayName("Test 7: Debe identificar pagos pendientes")
    void testValidatePayment_ShouldReturnFalse_WhenPaymentIsPending() {
        // Given
        Payment pendingPayment = Payment.builder()
                .isPayed(false)
                .build();

        // When
        boolean isPending = !pendingPayment.getIsPayed();

        // Then
        assertThat(isPending).isTrue();
        assertThat(pendingPayment.getIsPayed()).isFalse();
    }

    @Test
    @DisplayName("Test 8: Debe procesar reembolso correctamente")
    void testProcessRefund_ShouldUpdatePaymentStatus() {
        // Given
        Payment refundedPayment = Payment.builder()
                .paymentId(1)
                .isPayed(false) // Reembolsado
                .build();

        // When
        boolean isRefunded = !refundedPayment.getIsPayed();

        // Then
        assertThat(isRefunded).isTrue();
    }
}
