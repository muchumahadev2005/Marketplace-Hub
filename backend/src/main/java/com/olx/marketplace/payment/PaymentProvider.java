package com.olx.marketplace.payment;

import com.olx.marketplace.entity.Payment;
import com.olx.marketplace.entity.User;

import java.math.BigDecimal;

public interface PaymentProvider {
    String getProviderName();
    boolean isDevMode();
    PaymentOrderResult createOrder(User user, BigDecimal amount, String currency, String description);
    boolean verifyPayment(String providerPaymentId, String signature, String providerOrderId);
    boolean refundPayment(String providerPaymentId, BigDecimal amount);

    record PaymentOrderResult(
            String providerOrderId,
            String providerPaymentId,
            BigDecimal amount,
            String currency,
            String providerName,
            boolean isDevMode
    ) {}
}
