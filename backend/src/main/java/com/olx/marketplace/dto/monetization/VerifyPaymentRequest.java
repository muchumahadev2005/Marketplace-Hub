package com.olx.marketplace.dto.monetization;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class VerifyPaymentRequest {
    @NotNull(message = "Promotion ID is required")
    private Long promotionId;

    private String providerPaymentId;
    private String signature;
    private String orderId;
    private boolean devModeSimulatedSuccess; // Allowed only when app.payment.dev-mode=true
}
