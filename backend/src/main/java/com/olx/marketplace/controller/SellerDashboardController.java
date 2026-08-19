package com.olx.marketplace.controller;

import com.olx.marketplace.dto.monetization.SellerDashboardResponse;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.SellerDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/seller")
@RequiredArgsConstructor
public class SellerDashboardController {

    private final SellerDashboardService sellerDashboardService;

    @GetMapping("/dashboard")
    public ResponseEntity<SellerDashboardResponse> getSellerDashboard(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(sellerDashboardService.getSellerDashboard(currentUser));
    }
}
