package com.olx.marketplace.dto.monetization;

import com.olx.marketplace.entity.PromotionBanner;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PromotionBannerResponse {
    private Long id;
    private String title;
    private String description;
    private String imageUrl;
    private String targetUrl;

    public static PromotionBannerResponse fromEntity(PromotionBanner banner) {
        return PromotionBannerResponse.builder()
                .id(banner.getId())
                .title(banner.getTitle())
                .description(banner.getDescription())
                .imageUrl(banner.getImageUrl())
                .targetUrl(banner.getTargetUrl())
                .build();
    }
}
