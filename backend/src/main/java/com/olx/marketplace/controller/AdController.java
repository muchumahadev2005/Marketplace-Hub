package com.olx.marketplace.controller;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.dto.ad.CreateAdRequest;
import com.olx.marketplace.dto.common.ApiResponse;
import com.olx.marketplace.entity.AdCondition;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.AdService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/ads")
@RequiredArgsConstructor
public class AdController {

    private final AdService adService;

    @PostMapping
    public ResponseEntity<ApiResponse<AdResponse>> createAd(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateAdRequest request
    ) {
        AdResponse response = adService.createAd(currentUser, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Ad created successfully", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<AdResponse>>> getActiveAds(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Page<AdResponse> ads = adService.getActiveAds(page, size);
        return ResponseEntity.ok(ApiResponse.success("Active ads retrieved successfully", ads));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AdResponse>> getAdById(@PathVariable Long id) {
        AdResponse ad = adService.getAdById(id);
        return ResponseEntity.ok(ApiResponse.success("Ad details retrieved successfully", ad));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<AdResponse>>> getMyAds(@AuthenticationPrincipal User currentUser) {
        List<AdResponse> myAds = adService.getMyAds(currentUser);
        return ResponseEntity.ok(ApiResponse.success("My ads retrieved successfully", myAds));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<Page<AdResponse>>> searchAds(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long subcategoryId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) AdCondition condition,
            @RequestParam(required = false) String location,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Page<AdResponse> results = adService.searchAds(
                keyword, categoryId, subcategoryId, minPrice, maxPrice, condition, location, page, size
        );
        return ResponseEntity.ok(ApiResponse.success("Search results retrieved successfully", results));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<AdResponse>> updateAd(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateAdRequest request
    ) {
        AdResponse response = adService.updateAd(id, currentUser, request);
        return ResponseEntity.ok(ApiResponse.success("Ad updated successfully", response));
    }

    @PatchMapping("/{id}/sold")
    public ResponseEntity<ApiResponse<Void>> markAsSold(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        adService.markAsSold(id, currentUser);
        return ResponseEntity.ok(ApiResponse.success("Ad marked as SOLD", null));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteAd(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        adService.deleteAd(id, currentUser);
        return ResponseEntity.ok(ApiResponse.success("Ad deleted successfully", null));
    }
}
