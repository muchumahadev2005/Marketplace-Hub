package com.olx.marketplace.controller;

import com.olx.marketplace.dto.monetization.AdPromotionResponse;
import com.olx.marketplace.dto.monetization.CreatePromotionRequest;
import com.olx.marketplace.dto.monetization.PromotionPlanResponse;
import com.olx.marketplace.dto.monetization.VerifyPaymentRequest;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.PromotionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import com.olx.marketplace.dto.monetization.RazorpayOrderResponse;

@RestController
@RequestMapping("/api/promotions")
@RequiredArgsConstructor
public class PromotionController {

    private final PromotionService promotionService;

    @GetMapping("/plans")
    public ResponseEntity<List<PromotionPlanResponse>> getActivePlans() {
        return ResponseEntity.ok(promotionService.getActivePlans());
    }

    @PostMapping
    public ResponseEntity<RazorpayOrderResponse> createPromotionOrder(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreatePromotionRequest request
    ) {
        return ResponseEntity.ok(promotionService.createRazorpayPromotionOrder(currentUser, request));
    }

    @PostMapping("/{id}/verify")
    public ResponseEntity<AdPromotionResponse> verifyPayment(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id,
            @RequestBody VerifyPaymentRequest request
    ) {
        request.setPromotionId(id);
        return ResponseEntity.ok(promotionService.verifyAndActivatePromotion(currentUser, request));
    }

    @GetMapping("/my")
    public ResponseEntity<List<AdPromotionResponse>> getMyPromotions(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(promotionService.getMyPromotions(currentUser));
    }
}
