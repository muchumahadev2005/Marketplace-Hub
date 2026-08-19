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
public class CreateSubscriptionOrderRequest {
    @NotBlank(message = "Plan name is required (e.g. PREMIUM or BUSINESS)")
    private String planName;
}
