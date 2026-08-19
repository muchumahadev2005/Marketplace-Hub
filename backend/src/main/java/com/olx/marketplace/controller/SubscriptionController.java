package com.olx.marketplace.controller;

import com.olx.marketplace.dto.monetization.SellerSubscriptionResponse;
import com.olx.marketplace.dto.monetization.SubscriptionPlanResponse;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.SubscriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/subscriptions")
@RequiredArgsConstructor
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    @GetMapping("/plans")
    public ResponseEntity<List<SubscriptionPlanResponse>> getAvailableSubscriptionPlans() {
        return ResponseEntity.ok(subscriptionService.getAvailableSubscriptionPlans());
    }

    @GetMapping("/me")
    public ResponseEntity<SellerSubscriptionResponse> getCurrentSubscription(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(subscriptionService.getCurrentSubscription(currentUser));
    }

    @PostMapping("/subscribe")
    public ResponseEntity<SellerSubscriptionResponse> subscribePlan(
            @AuthenticationPrincipal User currentUser,
            @RequestParam String planName
    ) {
        return ResponseEntity.ok(subscriptionService.subscribePlan(currentUser, planName));
    }

    @PostMapping("/order")
    public ResponseEntity<com.olx.marketplace.dto.monetization.RazorpayOrderResponse> createSubscriptionOrder(
            @AuthenticationPrincipal User currentUser,
            @jakarta.validation.Valid @RequestBody com.olx.marketplace.dto.monetization.CreateSubscriptionOrderRequest request
    ) {
        return ResponseEntity.ok(subscriptionService.createRazorpaySubscriptionOrder(currentUser, request.getPlanName()));
    }

    @PostMapping("/verify")
    public ResponseEntity<com.olx.marketplace.dto.monetization.PaymentVerificationResponse> verifySubscriptionPayment(
            @AuthenticationPrincipal User currentUser,
            @jakarta.validation.Valid @RequestBody com.olx.marketplace.dto.monetization.PaymentVerificationRequest request
    ) {
        return ResponseEntity.ok(subscriptionService.verifyAndActivateSubscription(currentUser, request));
    }
}
