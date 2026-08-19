package com.olx.marketplace.dto.monetization;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RazorpayOrderResponse {
    private String orderId;       // e.g. "order_Mxxx..."
    private String keyId;         // e.g. "rzp_test_..."
    private Long amount;          // Smallest currency unit (paise, e.g. 9900 for ₹99.00)
    private BigDecimal amountInRupees; // Display price in Rupees (e.g. ₹99.00)
    private String currency;      // "INR"
    private Long promotionId;     // Database pending promotion ID
    private String promotionPlanName;
    private String adTitle;
}
