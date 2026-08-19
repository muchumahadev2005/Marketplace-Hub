package com.olx.marketplace.repository;

import com.olx.marketplace.entity.PromotionPlan;
import com.olx.marketplace.entity.PromotionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PromotionPlanRepository extends JpaRepository<PromotionPlan, Long> {
    List<PromotionPlan> findByActiveTrue();
    List<PromotionPlan> findByTypeAndActiveTrue(PromotionType type);
}
