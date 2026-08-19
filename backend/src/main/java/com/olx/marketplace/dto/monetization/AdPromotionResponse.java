package com.olx.marketplace.dto.monetization;

import com.olx.marketplace.entity.AdPromotion;
import com.olx.marketplace.entity.PromotionStatus;
import com.olx.marketplace.entity.PromotionType;
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
public class AdPromotionResponse {
    private Long id;
    private Long adId;
    private String adTitle;
    private String adImageUrl;
    private PromotionType promotionType;
    private PromotionStatus status;
    private BigDecimal price;
    private String formattedPrice;
    private Integer durationDays;
    private LocalDateTime startedAt;
    private LocalDateTime expiresAt;
    private String paymentId;
    private LocalDateTime createdAt;
    private String orderId;

    public static AdPromotionResponse fromEntity(AdPromotion promotion) {
        return AdPromotionResponse.builder()
                .id(promotion.getId())
                .adId(promotion.getAd() != null ? promotion.getAd().getId() : null)
                .adTitle(promotion.getAd() != null ? promotion.getAd().getTitle() : null)
                .adImageUrl(promotion.getAd() != null && !promotion.getAd().getImages().isEmpty()
                        ? promotion.getAd().getImages().get(0).getImageUrl()
                        : "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&q=80")
                .promotionType(promotion.getPromotionType())
                .status(promotion.getStatus())
                .price(promotion.getPrice())
                .formattedPrice("₹" + (promotion.getPrice() != null ? promotion.getPrice().toPlainString() : "0"))
                .durationDays(promotion.getDurationDays())
                .startedAt(promotion.getStartedAt())
                .expiresAt(promotion.getExpiresAt())
                .paymentId(promotion.getPaymentId())
                .createdAt(promotion.getCreatedAt())
                .build();
    }
}
