package com.olx.marketplace.service;

import com.olx.marketplace.dto.monetization.SellerDashboardResponse;
import com.olx.marketplace.dto.monetization.SellerSubscriptionResponse;
import com.olx.marketplace.entity.Ad;
import com.olx.marketplace.entity.AdStatus;
import com.olx.marketplace.entity.PromotionStatus;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.repository.AdPromotionRepository;
import com.olx.marketplace.repository.AdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SellerDashboardService {

    private final AdRepository adRepository;
    private final AdPromotionRepository adPromotionRepository;
    private final SubscriptionService subscriptionService;

    @Transactional(readOnly = true)
    public SellerDashboardResponse getSellerDashboard(User currentUser) {
        if (currentUser == null) {
            throw new com.olx.marketplace.exception.BadRequestException("Authentication required to view seller dashboard");
        }
        List<Ad> userAds = adRepository.findBySellerIdAndStatusNotOrderByCreatedAtDesc(currentUser.getId(), AdStatus.DELETED);

        int activeAdsCount = (int) userAds.stream().filter(a -> a.getStatus() == AdStatus.ACTIVE).count();
        int featuredAdsCount = (int) userAds.stream().filter(a -> a.isFeatured() && a.getStatus() == AdStatus.ACTIVE).count();
        long totalViews = userAds.stream().mapToLong(a -> a.getViews() != null ? a.getViews() : 0).sum();
        int totalPromotionsCount = (int) adPromotionRepository.countByUserIdAndStatus(currentUser.getId(), PromotionStatus.ACTIVE);

        SellerSubscriptionResponse currentSub = subscriptionService.getCurrentSubscription(currentUser);

        return SellerDashboardResponse.builder()
                .sellerType(currentUser.getSellerType() != null ? currentUser.getSellerType() : "FREE")
                .businessVerified(currentUser.isBusinessVerified())
                .activeAdsCount(activeAdsCount)
                .adLimit(currentSub.getAdLimit())
                .featuredAdsCount(featuredAdsCount)
                .totalPromotionsCount(totalPromotionsCount)
                .totalViews(totalViews)
                .currentSubscription(currentSub)
                .build();
    }
}
