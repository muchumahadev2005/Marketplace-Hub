package com.olx.marketplace.dto.monetization;

import com.olx.marketplace.entity.PromotionPlan;
import com.olx.marketplace.entity.PromotionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PromotionPlanResponse {
    private Long id;
    private String name;
    private PromotionType type;
    private Integer durationDays;
    private BigDecimal price;
    private String formattedPrice;
    private String description;

    public static PromotionPlanResponse fromEntity(PromotionPlan plan) {
        return PromotionPlanResponse.builder()
                .id(plan.getId())
                .name(plan.getName())
                .type(plan.getType())
                .durationDays(plan.getDurationDays())
                .price(plan.getPrice())
                .formattedPrice("₹" + (plan.getPrice() != null ? plan.getPrice().toPlainString() : "0"))
                .description(plan.getDescription())
                .build();
    }
}
