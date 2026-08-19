package com.olx.marketplace.service;

import com.olx.marketplace.config.RazorpayConfig;
import com.olx.marketplace.dto.monetization.CreatePromotionRequest;
import com.olx.marketplace.dto.monetization.RazorpayOrderResponse;
import com.olx.marketplace.entity.*;
import com.olx.marketplace.exception.BadRequestException;
import com.olx.marketplace.exception.ResourceNotFoundException;
import com.olx.marketplace.repository.AdPromotionRepository;
import com.olx.marketplace.repository.AdRepository;
import com.olx.marketplace.repository.PromotionPlanRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PromotionServiceTest {

    @Mock
    private PromotionPlanRepository promotionPlanRepository;

    @Mock
    private AdPromotionRepository adPromotionRepository;

    @Mock
    private AdRepository adRepository;

    @Mock
    private PaymentService paymentService;

    @Mock
    private RazorpayConfig razorpayConfig;

    @InjectMocks
    private PromotionService promotionService;

    private User owner;
    private User attacker;
    private Ad ad;
    private PromotionPlan activePlan;
    private PromotionPlan inactivePlan;

    @BeforeEach
    void setUp() {
        owner = User.builder().id(100L).name("Ad Owner").email("owner@olx.com").build();
        attacker = User.builder().id(200L).name("Attacker").email("attacker@olx.com").build();

        ad = Ad.builder().id(1L).title("Test iPhone 14").seller(owner).price(new BigDecimal("50000")).build();

        activePlan = PromotionPlan.builder()
                .id(1L)
                .name("Featured (3 Days)")
                .type(PromotionType.FEATURED)
                .durationDays(3)
                .price(new BigDecimal("99.00"))
                .active(true)
                .build();

        inactivePlan = PromotionPlan.builder()
                .id(2L)
                .name("Old Inactive Plan")
                .type(PromotionType.FEATURED)
                .durationDays(3)
                .price(new BigDecimal("49.00"))
                .active(false)
                .build();
    }

    @Test
    @DisplayName("1. Valid authenticated user creates Razorpay Order successfully")
    void testCreateRazorpayOrder_Success() {
        CreatePromotionRequest request = new CreatePromotionRequest();
        request.setAdId(1L);
        request.setPlanId(1L);

        when(adRepository.findById(1L)).thenReturn(Optional.of(ad));
        when(promotionPlanRepository.findById(1L)).thenReturn(Optional.of(activePlan));
        when(razorpayConfig.getKeyId()).thenReturn("rzp_test_KEY123");

        Payment mockPayment = Payment.builder()
                .id(50L)
                .user(owner)
                .amount(new BigDecimal("99.00"))
                .currency("INR")
                .status(PaymentStatus.PENDING)
                .provider("RAZORPAY")
                .providerOrderId("order_rzp_12345")
                .build();

        when(paymentService.createPaymentOrder(eq(owner), eq(new BigDecimal("99.00")), anyString()))
                .thenReturn(mockPayment);

        AdPromotion mockPromo = AdPromotion.builder()
                .id(99L)
                .ad(ad)
                .user(owner)
                .promotionType(PromotionType.FEATURED)
                .status(PromotionStatus.PENDING)
                .price(new BigDecimal("99.00"))
                .paymentId("50")
                .build();

        when(adPromotionRepository.save(any(AdPromotion.class))).thenReturn(mockPromo);

        RazorpayOrderResponse response = promotionService.createRazorpayPromotionOrder(owner, request);

        assertNotNull(response);
        assertEquals("order_rzp_12345", response.getOrderId());
        assertEquals("rzp_test_KEY123", response.getKeyId());
        assertEquals(9900L, response.getAmount()); // 99.00 INR = 9900 paise
        assertEquals("INR", response.getCurrency());
        assertEquals(99L, response.getPromotionId());
        assertEquals("Featured (3 Days)", response.getPromotionPlanName());
    }

    @Test
    @DisplayName("2. User cannot create promotion order for another user's ad")
    void testCreateRazorpayOrder_OwnershipMismatch() {
        CreatePromotionRequest request = new CreatePromotionRequest();
        request.setAdId(1L);
        request.setPlanId(1L);

        when(adRepository.findById(1L)).thenReturn(Optional.of(ad));

        BadRequestException ex = assertThrows(BadRequestException.class, () -> {
            promotionService.createRazorpayPromotionOrder(attacker, request);
        });

        assertTrue(ex.getMessage().contains("not authorized"));
        verify(paymentService, never()).createPaymentOrder(any(), any(), any());
    }

    @Test
    @DisplayName("3. Invalid promotion plan ID is rejected (404)")
    void testCreateRazorpayOrder_InvalidPlan() {
        CreatePromotionRequest request = new CreatePromotionRequest();
        request.setAdId(1L);
        request.setPlanId(999L);

        when(adRepository.findById(1L)).thenReturn(Optional.of(ad));
        when(promotionPlanRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> {
            promotionService.createRazorpayPromotionOrder(owner, request);
        });
    }

    @Test
    @DisplayName("4. Inactive promotion plan is rejected (400)")
    void testCreateRazorpayOrder_InactivePlan() {
        CreatePromotionRequest request = new CreatePromotionRequest();
        request.setAdId(1L);
        request.setPlanId(2L);

        when(adRepository.findById(1L)).thenReturn(Optional.of(ad));
        when(promotionPlanRepository.findById(2L)).thenReturn(Optional.of(inactivePlan));

        BadRequestException ex = assertThrows(BadRequestException.class, () -> {
            promotionService.createRazorpayPromotionOrder(owner, request);
        });

        assertTrue(ex.getMessage().contains("no longer active"));
    }

    @Test
    @DisplayName("5. Server uses DB plan price and ignores any client price tampering")
    void testCreateRazorpayOrder_PriceAuthority() {
        CreatePromotionRequest request = new CreatePromotionRequest();
        request.setAdId(1L);
        request.setPlanId(1L);

        when(adRepository.findById(1L)).thenReturn(Optional.of(ad));
        when(promotionPlanRepository.findById(1L)).thenReturn(Optional.of(activePlan));
        when(razorpayConfig.getKeyId()).thenReturn("rzp_test_KEY123");

        Payment mockPayment = Payment.builder()
                .id(50L)
                .user(owner)
                .amount(activePlan.getPrice())
                .currency("INR")
                .providerOrderId("order_rzp_12345")
                .build();

        when(paymentService.createPaymentOrder(eq(owner), eq(new BigDecimal("99.00")), anyString()))
                .thenReturn(mockPayment);

        AdPromotion mockPromo = AdPromotion.builder().id(99L).ad(ad).user(owner).price(new BigDecimal("99.00")).paymentId("50").build();
        when(adPromotionRepository.save(any(AdPromotion.class))).thenReturn(mockPromo);

        RazorpayOrderResponse response = promotionService.createRazorpayPromotionOrder(owner, request);

        // Price in paise is derived strictly from activePlan.getPrice() (99.00 -> 9900)
        assertEquals(9900L, response.getAmount());
    }

    @Test
    @DisplayName("6. Razorpay API failure is handled gracefully")
    void testCreateRazorpayOrder_RazorpayFailure() {
        CreatePromotionRequest request = new CreatePromotionRequest();
        request.setAdId(1L);
        request.setPlanId(1L);

        when(adRepository.findById(1L)).thenReturn(Optional.of(ad));
        when(promotionPlanRepository.findById(1L)).thenReturn(Optional.of(activePlan));

        when(paymentService.createPaymentOrder(any(), any(), any()))
                .thenThrow(new RuntimeException("Failed to create Razorpay Order: API connection failed"));

        RuntimeException ex = assertThrows(RuntimeException.class, () -> {
            promotionService.createRazorpayPromotionOrder(owner, request);
        });

        assertTrue(ex.getMessage().contains("Razorpay Order"));
    }

    @Test
    @DisplayName("7. Razorpay Key Secret is NEVER exposed in the response DTO")
    void testCreateRazorpayOrder_SecretNeverExposed() {
        RazorpayOrderResponse response = RazorpayOrderResponse.builder()
                .orderId("order_test_123")
                .keyId("rzp_test_public_key")
                .amount(9900L)
                .currency("INR")
                .build();

        String responseString = response.toString();
        assertFalse(responseString.toLowerCase().contains("secret"));
    }
}
