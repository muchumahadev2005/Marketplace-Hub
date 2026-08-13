package com.olx.marketplace.controller;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.dto.common.ApiResponse;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping("/{adId}")
    public ResponseEntity<ApiResponse<Void>> addFavorite(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long adId
    ) {
        favoriteService.addFavorite(currentUser, adId);
        return ResponseEntity.ok(ApiResponse.success("Ad added to favorites", null));
    }

    @DeleteMapping("/{adId}")
    public ResponseEntity<ApiResponse<Void>> removeFavorite(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long adId
    ) {
        favoriteService.removeFavorite(currentUser, adId);
        return ResponseEntity.ok(ApiResponse.success("Ad removed from favorites", null));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<AdResponse>>> getMyFavorites(@AuthenticationPrincipal User currentUser) {
        List<AdResponse> favorites = favoriteService.getMyFavorites(currentUser);
        return ResponseEntity.ok(ApiResponse.success("Favorites retrieved successfully", favorites));
    }
}
