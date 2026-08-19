package com.olx.marketplace.dto.monetization;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubscriptionPlanResponse {
    private String planName; // FREE, PREMIUM, BUSINESS
    private BigDecimal monthlyPrice;
    private String formattedPrice;
    private Integer adLimit;
    private List<String> features;
}
