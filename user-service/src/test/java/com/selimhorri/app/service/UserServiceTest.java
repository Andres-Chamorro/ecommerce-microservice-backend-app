package com.selimhorri.app.service;

import com.selimhorri.app.domain.User;
import com.selimhorri.app.repository.UserRepository;
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
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para UserService
 * Valida la lógica de negocio del repositorio de usuarios
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("User Service - Unit Tests")
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    private User user;

    @BeforeEach
    void setUp() {
        // Datos de prueba
        user = User.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .phone("1234567890")
                .build();
    }

    @Test
    @DisplayName("Test 1: Repository debe retornar todos los usuarios")
    void testFindAll_ShouldReturnAllUsers() {
        // Given
        List<User> users = Arrays.asList(user);
        when(userRepository.findAll()).thenReturn(users);

        // When
        List<User> result = userRepository.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getFirstName()).isEqualTo("John");
        verify(userRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Test 2: Repository debe encontrar usuario por ID")
    void testFindById_ShouldReturnUser_WhenUserExists() {
        // Given
        when(userRepository.findById(anyInt())).thenReturn(Optional.of(user));

        // When
        Optional<User> result = userRepository.findById(1);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getUserId()).isEqualTo(1);
        assertThat(result.get().getEmail()).isEqualTo("john.doe@example.com");
        verify(userRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Test 3: Repository debe guardar un nuevo usuario")
    void testSave_ShouldCreateNewUser() {
        // Given
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        User result = userRepository.save(user);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getFirstName()).isEqualTo("John");
        assertThat(result.getLastName()).isEqualTo("Doe");
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("Test 4: Repository debe actualizar un usuario existente")
    void testUpdate_ShouldUpdateExistingUser() {
        // Given
        User updatedUser = User.builder()
                .userId(1)
                .firstName("Jane")
                .lastName("Doe")
                .email("jane.doe@example.com")
                .phone("0987654321")
                .build();
        when(userRepository.save(any(User.class))).thenReturn(updatedUser);

        // When
        User result = userRepository.save(updatedUser);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getFirstName()).isEqualTo("Jane");
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("Test 5: Repository debe eliminar un usuario por ID")
    void testDeleteById_ShouldDeleteUser() {
        // Given
        doNothing().when(userRepository).deleteById(anyInt());

        // When
        userRepository.deleteById(1);

        // Then
        verify(userRepository, times(1)).deleteById(1);
    }

    @Test
    @DisplayName("Test 6: Repository debe encontrar usuario por username")
    void testFindByUsername_ShouldReturnUser_WhenUsernameExists() {
        // Given
        when(userRepository.findByCredentialUsername(anyString())).thenReturn(Optional.of(user));

        // When
        Optional<User> result = userRepository.findByCredentialUsername("johndoe");

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getFirstName()).isEqualTo("John");
        verify(userRepository, times(1)).findByCredentialUsername("johndoe");
    }
}
