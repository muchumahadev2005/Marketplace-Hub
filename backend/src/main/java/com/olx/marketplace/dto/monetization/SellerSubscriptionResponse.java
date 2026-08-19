package com.olx.marketplace.dto.monetization;

import com.olx.marketplace.entity.SellerSubscription;
import com.olx.marketplace.entity.SubscriptionStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerSubscriptionResponse {
    private Long id;
    private String planName;
    private SubscriptionStatus status;
    private Integer adLimit;
    private Integer activeAdsCount;
    private BigDecimal price;
    private String formattedPrice;
    private LocalDateTime startedAt;
    private LocalDateTime expiresAt;

    public static SellerSubscriptionResponse fromEntity(SellerSubscription sub, int activeAdsCount) {
        return SellerSubscriptionResponse.builder()
                .id(sub.getId())
                .planName(sub.getPlanName())
                .status(sub.getStatus())
                .adLimit(sub.getAdLimit())
                .activeAdsCount(activeAdsCount)
                .price(sub.getPrice())
                .formattedPrice("₹" + (sub.getPrice() != null ? sub.getPrice().toPlainString() : "0"))
                .startedAt(sub.getStartedAt())
                .expiresAt(sub.getExpiresAt())
                .build();
    }
}
