package com.olx.marketplace.repository;

import com.olx.marketplace.entity.SellerSubscription;
import com.olx.marketplace.entity.SubscriptionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SellerSubscriptionRepository extends JpaRepository<SellerSubscription, Long> {
    Optional<SellerSubscription> findFirstByUserIdAndStatusOrderByCreatedAtDesc(Long userId, SubscriptionStatus status);
}
