package com.olx.marketplace.dto.monetization;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerDashboardResponse {
    private String sellerType; // FREE, PREMIUM, BUSINESS
    private boolean businessVerified;
    private int activeAdsCount;
    private int adLimit;
    private int featuredAdsCount;
    private int totalPromotionsCount;
    private long totalViews;
    private SellerSubscriptionResponse currentSubscription;
}
