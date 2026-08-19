package com.olx.marketplace.controller;

import com.olx.marketplace.dto.monetization.PromotionBannerResponse;
import com.olx.marketplace.service.PromotionBannerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/banners")
@RequiredArgsConstructor
public class BannerController {

    private final PromotionBannerService promotionBannerService;

    @GetMapping
    public ResponseEntity<List<PromotionBannerResponse>> getActiveBanners() {
        return ResponseEntity.ok(promotionBannerService.getActiveBanners());
    }
}
