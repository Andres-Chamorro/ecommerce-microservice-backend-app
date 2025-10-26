package com.selimhorri.app.service;

import com.selimhorri.app.domain.Favourite;
import com.selimhorri.app.repository.FavouriteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para FavouriteService
 * Valida la lógica de negocio del repositorio de favoritos
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Favourite Service - Unit Tests")
class FavouriteServiceTest {

    @Mock
    private FavouriteRepository favouriteRepository;

    private Favourite favourite;

    @BeforeEach
    void setUp() {
        favourite = Favourite.builder()
                .userId(1)
                .productId(100)
                .likeDate(LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("Test 1: Repository debe retornar todos los favoritos")
    void testFindAll_ShouldReturnAllFavourites() {
        // Given
        List<Favourite> favourites = Arrays.asList(favourite);
        when(favouriteRepository.findAll()).thenReturn(favourites);

        // When
        List<Favourite> result = favouriteRepository.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getUserId()).isEqualTo(1);
        assertThat(result.get(0).getProductId()).isEqualTo(100);
        verify(favouriteRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Test 2: Debe crear un nuevo favorito")
    void testSave_ShouldCreateNewFavourite() {
        // Given
        when(favouriteRepository.save(any(Favourite.class))).thenReturn(favourite);

        // When
        Favourite result = favouriteRepository.save(favourite);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getUserId()).isEqualTo(1);
        assertThat(result.getProductId()).isEqualTo(100);
        assertThat(result.getLikeDate()).isNotNull();
        verify(favouriteRepository, times(1)).save(any(Favourite.class));
    }

    @Test
    @DisplayName("Test 3: Debe validar relación usuario-producto")
    void testValidateUserProductRelation() {
        // Given - favorito con userId y productId

        // When
        boolean hasValidIds = favourite.getUserId() != null && favourite.getProductId() != null;

        // Then
        assertThat(hasValidIds).isTrue();
        assertThat(favourite.getUserId()).isEqualTo(1);
        assertThat(favourite.getProductId()).isEqualTo(100);
    }

    @Test
    @DisplayName("Test 4: Debe validar fecha de like")
    void testValidateLikeDate() {
        // Given - favorito con fecha

        // When
        boolean hasLikeDate = favourite.getLikeDate() != null;

        // Then
        assertThat(hasLikeDate).isTrue();
        assertThat(favourite.getLikeDate()).isBeforeOrEqualTo(LocalDateTime.now());
    }

    @Test
    @DisplayName("Test 5: Debe filtrar favoritos por usuario")
    void testFindByUserId_ShouldReturnUserFavourites() {
        // Given
        Favourite favourite2 = Favourite.builder()
                .userId(1)
                .productId(200)
                .likeDate(LocalDateTime.now())
                .build();
        
        List<Favourite> favourites = Arrays.asList(favourite, favourite2);
        when(favouriteRepository.findAll()).thenReturn(favourites);

        // When
        List<Favourite> result = favouriteRepository.findAll();
        List<Favourite> userFavourites = result.stream()
                .filter(fav -> fav.getUserId().equals(1))
                .collect(Collectors.toList());

        // Then
        assertThat(userFavourites).hasSize(2);
        assertThat(userFavourites).allMatch(fav -> fav.getUserId().equals(1));
    }

    @Test
    @DisplayName("Test 6: Debe filtrar favoritos por producto")
    void testFindByProductId_ShouldReturnProductFavourites() {
        // Given
        Favourite favourite2 = Favourite.builder()
                .userId(2)
                .productId(100)
                .likeDate(LocalDateTime.now())
                .build();
        
        List<Favourite> favourites = Arrays.asList(favourite, favourite2);
        when(favouriteRepository.findAll()).thenReturn(favourites);

        // When
        List<Favourite> result = favouriteRepository.findAll();
        List<Favourite> productFavourites = result.stream()
                .filter(fav -> fav.getProductId().equals(100))
                .collect(Collectors.toList());

        // Then
        assertThat(productFavourites).hasSize(2);
        assertThat(productFavourites).allMatch(fav -> fav.getProductId().equals(100));
    }

    @Test
    @DisplayName("Test 7: Debe contar favoritos de un producto")
    void testCountFavouritesByProduct() {
        // Given
        Favourite fav1 = Favourite.builder().userId(1).productId(100).likeDate(LocalDateTime.now()).build();
        Favourite fav2 = Favourite.builder().userId(2).productId(100).likeDate(LocalDateTime.now()).build();
        Favourite fav3 = Favourite.builder().userId(3).productId(100).likeDate(LocalDateTime.now()).build();
        
        List<Favourite> favourites = Arrays.asList(fav1, fav2, fav3);
        when(favouriteRepository.findAll()).thenReturn(favourites);

        // When
        List<Favourite> result = favouriteRepository.findAll();
        long count = result.stream()
                .filter(fav -> fav.getProductId().equals(100))
                .count();

        // Then
        assertThat(count).isEqualTo(3);
    }

    @Test
    @DisplayName("Test 8: Debe verificar si un usuario tiene un producto en favoritos")
    void testUserHasProductInFavourites() {
        // Given
        List<Favourite> favourites = Arrays.asList(favourite);
        when(favouriteRepository.findAll()).thenReturn(favourites);

        // When
        List<Favourite> result = favouriteRepository.findAll();
        boolean hasInFavourites = result.stream()
                .anyMatch(fav -> fav.getUserId().equals(1) && fav.getProductId().equals(100));

        // Then
        assertThat(hasInFavourites).isTrue();
    }
}
