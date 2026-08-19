package com.olx.marketplace.dto.monetization;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentVerificationRequest {

    @NotBlank(message = "Razorpay Order ID is required")
    private String razorpayOrderId;

    @NotBlank(message = "Razorpay Payment ID is required")
    private String razorpayPaymentId;

    @NotBlank(message = "Razorpay Signature is required")
    private String razorpaySignature;

    @NotBlank(message = "Payment type is required (SUBSCRIPTION or PROMOTION)")
    private String type;

    private String planName; // For SUBSCRIPTION type (PREMIUM or BUSINESS)

    private Long promotionId; // For PROMOTION type
}
