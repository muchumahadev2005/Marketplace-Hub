package com.olx.marketplace.service;

import com.olx.marketplace.dto.monetization.*;
import com.olx.marketplace.entity.*;
import com.olx.marketplace.exception.BadRequestException;
import com.olx.marketplace.exception.ResourceNotFoundException;
import com.olx.marketplace.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PromotionService {

    private final PromotionPlanRepository promotionPlanRepository;
    private final AdPromotionRepository adPromotionRepository;
    private final AdRepository adRepository;
    private final PaymentService paymentService;
    private final com.olx.marketplace.config.RazorpayConfig razorpayConfig;

    @Transactional(readOnly = true)
    public List<PromotionPlanResponse> getActivePlans() {
        return promotionPlanRepository.findByActiveTrue()
                .stream()
                .map(PromotionPlanResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public RazorpayOrderResponse createRazorpayPromotionOrder(User currentUser, CreatePromotionRequest request) {
        Ad ad = adRepository.findById(request.getAdId())
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + request.getAdId()));

        if (!ad.getSeller().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You are not authorized to promote this ad");
        }

        PromotionPlan plan = promotionPlanRepository.findById(request.getPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("Promotion plan not found with id: " + request.getPlanId()));

        if (!plan.isActive()) {
            throw new BadRequestException("This promotion plan is no longer active");
        }

        // Convert official PostgreSQL plan price to smallest currency unit (paise)
        long amountInPaise = plan.getPrice()
                .setScale(2, java.math.RoundingMode.HALF_UP)
                .multiply(new java.math.BigDecimal("100"))
                .longValueExact();

        // Create Payment order via Razorpay SDK (PaymentService -> RazorpayPaymentProvider)
        Payment payment = paymentService.createPaymentOrder(
                currentUser,
                plan.getPrice(),
                "Promotion: " + plan.getName() + " for Ad #" + ad.getId()
        );

        // Create PENDING AdPromotion record in PostgreSQL
        AdPromotion promotion = AdPromotion.builder()
                .ad(ad)
                .user(currentUser)
                .promotionType(plan.getType())
                .status(PromotionStatus.PENDING)
                .price(plan.getPrice())
                .durationDays(plan.getDurationDays())
                .paymentId(payment.getId().toString())
                .build();

        AdPromotion savedPromotion = adPromotionRepository.save(promotion);

        // Return Razorpay Order response to Flutter (NEVER returns secret key)
        return RazorpayOrderResponse.builder()
                .orderId(payment.getProviderOrderId())
                .keyId(razorpayConfig.getKeyId())
                .amount(amountInPaise)
                .amountInRupees(plan.getPrice())
                .currency("INR")
                .promotionId(savedPromotion.getId())
                .promotionPlanName(plan.getName())
                .adTitle(ad.getTitle())
                .build();
    }

    @Transactional
    public AdPromotionResponse verifyAndActivatePromotion(User currentUser, VerifyPaymentRequest request) {
        AdPromotion promotion = adPromotionRepository.findById(request.getPromotionId())
                .orElseThrow(() -> new ResourceNotFoundException("Promotion not found with id: " + request.getPromotionId()));

        if (!promotion.getUser().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You are not authorized to access this promotion");
        }

        Payment payment = paymentService.getPaymentById(Long.parseLong(promotion.getPaymentId()));

        boolean paymentVerified = paymentService.verifyPayment(
                payment,
                request.getProviderPaymentId(),
                request.getSignature(),
                request.isDevModeSimulatedSuccess()
        );

        if (!paymentVerified) {
            promotion.setStatus(PromotionStatus.FAILED);
            adPromotionRepository.save(promotion);
            throw new BadRequestException("Payment verification failed. Promotion not activated.");
        }

        // Activate Promotion
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusDays(promotion.getDurationDays() != null ? promotion.getDurationDays() : 3);

        promotion.setStatus(PromotionStatus.ACTIVE);
        promotion.setStartedAt(now);
        promotion.setExpiresAt(expiresAt);
        adPromotionRepository.save(promotion);

        // Update target Ad
        Ad ad = promotion.getAd();
        ad.setFeatured(true);
        ad.setFeaturedUntil(expiresAt);
        ad.setPromotionType(promotion.getPromotionType().name());
        adRepository.save(ad);

        return AdPromotionResponse.fromEntity(promotion);
    }

    @Transactional(readOnly = true)
    public List<AdPromotionResponse> getMyPromotions(User currentUser) {
        return adPromotionRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(AdPromotionResponse::fromEntity)
                .collect(Collectors.toList());
    }
}
