package com.olx.marketplace.dto.monetization;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreatePromotionRequest {
    @NotNull(message = "Ad ID is required")
    private Long adId;

    @NotNull(message = "Promotion Plan ID is required")
    private Long planId;
}
