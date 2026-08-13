package com.olx.marketplace.controller;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.dto.category.CategoryResponse;
import com.olx.marketplace.dto.common.ApiResponse;
import com.olx.marketplace.dto.home.HomeScreenResponse;
import com.olx.marketplace.service.AdService;
import com.olx.marketplace.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/home")
@RequiredArgsConstructor
public class HomeController {

    private final CategoryService categoryService;
    private final AdService adService;

    @GetMapping
    public ResponseEntity<ApiResponse<HomeScreenResponse>> getHomeScreenData() {
        List<CategoryResponse> categories = categoryService.getAllRootCategories();
        Page<AdResponse> recentAdsPage = adService.getActiveAds(0, 20);

        HomeScreenResponse response = HomeScreenResponse.builder()
                .categories(categories)
                .featuredAds(recentAdsPage.getContent())
                .recentAds(recentAdsPage.getContent())
                .build();

        return ResponseEntity.ok(ApiResponse.success("Home feed data retrieved successfully", response));
    }
}
