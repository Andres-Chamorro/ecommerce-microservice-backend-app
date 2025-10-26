package com.selimhorri.app.resource;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.service.UserService;
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
 * Pruebas Unitarias para UserResource (Controller)
 * Valida los endpoints REST del controlador de usuarios
 */
@WebMvcTest(UserResource.class)
@DisplayName("User Resource - Controller Unit Tests")
class UserResourceTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    private UserDto userDto;

    @BeforeEach
    void setUp() {
        userDto = UserDto.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .phone("1234567890")
                .build();
    }

    @Test
    @DisplayName("Test 1: GET /api/users - Debe retornar lista de usuarios")
    void testFindAll_ShouldReturnUsersList() throws Exception {
        // Given
        List<UserDto> users = Arrays.asList(userDto);
        when(userService.findAll()).thenReturn(users);

        // When & Then
        mockMvc.perform(get("/api/users")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.collection", hasSize(1)))
                .andExpect(jsonPath("$.collection[0].firstName", is("John")))
                .andExpect(jsonPath("$.collection[0].email", is("john.doe@example.com")));
    }

    @Test
    @DisplayName("Test 2: GET /api/users/{id} - Debe retornar usuario por ID")
    void testFindById_ShouldReturnUser() throws Exception {
        // Given
        when(userService.findById(anyInt())).thenReturn(userDto);

        // When & Then
        mockMvc.perform(get("/api/users/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId", is(1)))
                .andExpect(jsonPath("$.firstName", is("John")))
                .andExpect(jsonPath("$.lastName", is("Doe")));
    }

    @Test
    @DisplayName("Test 3: POST /api/users - Debe crear un nuevo usuario")
    void testSave_ShouldCreateNewUser() throws Exception {
        // Given
        when(userService.save(any(UserDto.class))).thenReturn(userDto);

        // When & Then
        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId", is(1)))
                .andExpect(jsonPath("$.firstName", is("John")));
    }

    @Test
    @DisplayName("Test 4: PUT /api/users - Debe actualizar un usuario")
    void testUpdate_ShouldUpdateUser() throws Exception {
        // Given
        UserDto updatedUser = UserDto.builder()
                .userId(1)
                .firstName("Jane")
                .lastName("Doe")
                .email("jane.doe@example.com")
                .phone("0987654321")
                .build();

        when(userService.update(any(UserDto.class))).thenReturn(updatedUser);

        // When & Then
        mockMvc.perform(put("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updatedUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName", is("Jane")))
                .andExpect(jsonPath("$.email", is("jane.doe@example.com")));
    }

    @Test
    @DisplayName("Test 5: DELETE /api/users/{id} - Debe eliminar un usuario")
    void testDeleteById_ShouldDeleteUser() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/users/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("true"));
    }

    @Test
    @DisplayName("Test 6: GET /api/users/username/{username} - Debe retornar usuario por username")
    void testFindByUsername_ShouldReturnUser() throws Exception {
        // Given
        when(userService.findByUsername("johndoe")).thenReturn(userDto);

        // When & Then
        mockMvc.perform(get("/api/users/username/johndoe")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName", is("John")))
                .andExpect(jsonPath("$.email", is("john.doe@example.com")));
    }
}
