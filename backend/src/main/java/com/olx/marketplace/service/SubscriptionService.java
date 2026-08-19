package com.olx.marketplace.service;

import com.olx.marketplace.dto.monetization.SellerSubscriptionResponse;
import com.olx.marketplace.dto.monetization.SubscriptionPlanResponse;
import com.olx.marketplace.entity.*;
import com.olx.marketplace.exception.BadRequestException;
import com.olx.marketplace.repository.AdRepository;
import com.olx.marketplace.repository.SellerSubscriptionRepository;
import com.olx.marketplace.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import com.olx.marketplace.dto.monetization.RazorpayOrderResponse;
import com.olx.marketplace.dto.monetization.PaymentVerificationRequest;
import com.olx.marketplace.dto.monetization.PaymentVerificationResponse;
import com.olx.marketplace.payment.PaymentProvider;
import com.olx.marketplace.payment.PaymentProvider.PaymentOrderResult;
import com.olx.marketplace.repository.PaymentRepository;

@Service
@RequiredArgsConstructor
public class SubscriptionService {

    private final SellerSubscriptionRepository subscriptionRepository;
    private final AdRepository adRepository;
    private final UserRepository userRepository;
    private final PaymentProvider paymentProvider;
    private final PaymentRepository paymentRepository;
    private final com.olx.marketplace.config.RazorpayConfig razorpayConfig;

    public List<SubscriptionPlanResponse> getAvailableSubscriptionPlans() {
        return List.of(
                SubscriptionPlanResponse.builder()
                        .planName("FREE")
                        .monthlyPrice(BigDecimal.ZERO)
                        .formattedPrice("₹0/mo")
                        .adLimit(5)
                        .features(List.of("5 Active Ads", "Standard Visibility", "Basic Analytics"))
                        .build(),
                SubscriptionPlanResponse.builder()
                        .planName("PREMIUM")
                        .monthlyPrice(new BigDecimal("499"))
                        .formattedPrice("₹499/mo")
                        .adLimit(25)
                        .features(List.of("25 Active Ads", "Increased Visibility", "Featured Badge Credits", "Detailed Analytics"))
                        .build(),
                SubscriptionPlanResponse.builder()
                        .planName("BUSINESS")
                        .monthlyPrice(new BigDecimal("1499"))
                        .formattedPrice("₹1,499/mo")
                        .adLimit(100)
                        .features(List.of("100 Active Ads", "Top Placement Priority", "Verified Business Badge", "Dedicated Support"))
                        .build()
        );
    }

    @Transactional(readOnly = true)
    public SellerSubscriptionResponse getCurrentSubscription(User currentUser) {
        if (currentUser == null) {
            return SellerSubscriptionResponse.builder()
                    .planName("FREE")
                    .status(SubscriptionStatus.ACTIVE)
                    .adLimit(5)
                    .activeAdsCount(0)
                    .price(BigDecimal.ZERO)
                    .formattedPrice("₹0")
                    .build();
        }
        int activeAdsCount = adRepository.findBySellerIdAndStatusOrderByCreatedAtDesc(currentUser.getId(), AdStatus.ACTIVE).size();

        return subscriptionRepository.findFirstByUserIdAndStatusOrderByCreatedAtDesc(currentUser.getId(), SubscriptionStatus.ACTIVE)
                .map(sub -> SellerSubscriptionResponse.fromEntity(sub, activeAdsCount))
                .orElseGet(() -> {
                    // Default Free Plan
                    SellerSubscription defaultSub = SellerSubscription.builder()
                            .user(currentUser)
                            .planName(currentUser.getSellerType() != null ? currentUser.getSellerType() : "FREE")
                            .status(SubscriptionStatus.ACTIVE)
                            .adLimit(getAdLimitForPlan(currentUser.getSellerType()))
                            .price(BigDecimal.ZERO)
                            .startedAt(LocalDateTime.now())
                            .build();
                    return SellerSubscriptionResponse.fromEntity(defaultSub, activeAdsCount);
                });
    }

    @Transactional
    public SellerSubscriptionResponse subscribePlan(User currentUser, String planName) {
        String planUpper = planName.toUpperCase().trim();
        if (!List.of("FREE", "PREMIUM", "BUSINESS").contains(planUpper)) {
            throw new BadRequestException("Invalid subscription plan: " + planName);
        }

        int limit = getAdLimitForPlan(planUpper);
        BigDecimal price = switch (planUpper) {
            case "PREMIUM" -> new BigDecimal("499");
            case "BUSINESS" -> new BigDecimal("1499");
            default -> BigDecimal.ZERO;
        };

        currentUser.setSellerType(planUpper);
        if ("BUSINESS".equals(planUpper)) {
            currentUser.setBusinessVerified(true);
        }
        userRepository.save(currentUser);

        SellerSubscription sub = SellerSubscription.builder()
                .user(currentUser)
                .planName(planUpper)
                .status(SubscriptionStatus.ACTIVE)
                .adLimit(limit)
                .price(price)
                .startedAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusDays(30))
                .build();

        SellerSubscription saved = subscriptionRepository.save(sub);
        int activeAdsCount = adRepository.findBySellerIdAndStatusOrderByCreatedAtDesc(currentUser.getId(), AdStatus.ACTIVE).size();
        return SellerSubscriptionResponse.fromEntity(saved, activeAdsCount);
    }

    public int getAdLimitForPlan(String planName) {
        if (planName == null) return 5;
        return switch (planName.toUpperCase()) {
            case "PREMIUM" -> 25;
            case "BUSINESS" -> 100;
            default -> 5;
        };
    }

    @Transactional
    public RazorpayOrderResponse createRazorpaySubscriptionOrder(User currentUser, String planName) {
        String planUpper = planName.toUpperCase().trim();
        if (!List.of("PREMIUM", "BUSINESS").contains(planUpper)) {
            throw new BadRequestException("Invalid paid subscription plan: " + planName);
        }

        BigDecimal price = "BUSINESS".equals(planUpper) ? new BigDecimal("1499") : new BigDecimal("499");
        PaymentOrderResult orderResult = paymentProvider.createOrder(
                currentUser,
                price,
                "INR",
                "OLX Marketplace " + planUpper + " Subscription"
        );

        Payment payment = Payment.builder()
                .user(currentUser)
                .amount(price)
                .currency("INR")
                .provider("RAZORPAY")
                .providerOrderId(orderResult.providerOrderId())
                .status(PaymentStatus.PENDING)
                .build();
        paymentRepository.save(payment);

        long amountInPaise = price.multiply(new BigDecimal("100")).longValue();

        return RazorpayOrderResponse.builder()
                .orderId(orderResult.providerOrderId())
                .keyId(razorpayConfig.getKeyId())
                .amount(amountInPaise)
                .amountInRupees(price)
                .currency("INR")
                .promotionPlanName(planUpper + " Subscription")
                .build();
    }

    @Transactional
    public PaymentVerificationResponse verifyAndActivateSubscription(User currentUser, PaymentVerificationRequest request) {
        boolean isValid = paymentProvider.verifyPayment(
                request.getRazorpayPaymentId(),
                request.getRazorpaySignature(),
                request.getRazorpayOrderId()
        );

        if (!isValid) {
            throw new BadRequestException("Payment verification failed. Invalid Razorpay signature.");
        }

        Payment payment = paymentRepository.findByProviderOrderId(request.getRazorpayOrderId())
                .orElseThrow(() -> new BadRequestException("Payment record not found for order ID: " + request.getRazorpayOrderId()));

        payment.setStatus(PaymentStatus.SUCCESS);
        payment.setProviderPaymentId(request.getRazorpayPaymentId());
        paymentRepository.save(payment);

        String planUpper = request.getPlanName() != null ? request.getPlanName().toUpperCase() : "PREMIUM";
        subscribePlan(currentUser, planUpper);

        return PaymentVerificationResponse.builder()
                .success(true)
                .message("Subscription activated successfully!")
                .paymentId(request.getRazorpayPaymentId())
                .status("SUCCESS")
                .planName(planUpper)
                .build();
    }
}
