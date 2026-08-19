package com.olx.marketplace.scheduler;

import com.olx.marketplace.entity.Ad;
import com.olx.marketplace.entity.AdPromotion;
import com.olx.marketplace.entity.PromotionStatus;
import com.olx.marketplace.repository.AdPromotionRepository;
import com.olx.marketplace.repository.AdRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class PromotionScheduledTask {

    private final AdPromotionRepository adPromotionRepository;
    private final AdRepository adRepository;

    // Run every 10 minutes to clean up expired promotions
    @Scheduled(fixedRate = 600000)
    @Transactional
    public void expirePromotions() {
        LocalDateTime now = LocalDateTime.now();
        List<AdPromotion> expiredPromotions = adPromotionRepository.findByStatusAndExpiresAtBefore(PromotionStatus.ACTIVE, now);

        if (!expiredPromotions.isEmpty()) {
            log.info("Found {} expired promotions to deactivate", expiredPromotions.size());
            for (AdPromotion promo : expiredPromotions) {
                promo.setStatus(PromotionStatus.EXPIRED);
                adPromotionRepository.save(promo);

                Ad ad = promo.getAd();
                if (ad != null) {
                    ad.setFeatured(false);
                    ad.setPromotionType("NONE");
                    adRepository.save(ad);
                }
            }
        }
    }
}
