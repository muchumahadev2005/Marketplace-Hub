package com.olx.marketplace.repository;

import com.olx.marketplace.entity.AdPromotion;
import com.olx.marketplace.entity.PromotionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AdPromotionRepository extends JpaRepository<AdPromotion, Long> {
    List<AdPromotion> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<AdPromotion> findByAdIdOrderByCreatedAtDesc(Long adId);
    Optional<AdPromotion> findByAdIdAndStatus(Long adId, PromotionStatus status);
    List<AdPromotion> findByStatusAndExpiresAtBefore(PromotionStatus status, LocalDateTime now);
    long countByUserIdAndStatus(Long userId, PromotionStatus status);
}
