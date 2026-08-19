package com.olx.marketplace.payment;

import com.olx.marketplace.entity.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.UUID;

@Component
public class MockPaymentProvider implements PaymentProvider {

    @Value("${app.payment.dev-mode:true}")
    private boolean devMode;

    @Override
    public String getProviderName() {
        return "MOCK_GATEWAY";
    }

    @Override
    public boolean isDevMode() {
        return devMode;
    }

    @Override
    public PaymentOrderResult createOrder(User user, BigDecimal amount, String currency, String description) {
        String orderId = "order_dev_" + UUID.randomUUID().toString().substring(0, 8);
        String paymentId = "pay_dev_" + UUID.randomUUID().toString().substring(0, 8);

        return new PaymentOrderResult(
                orderId,
                paymentId,
                amount,
                currency != null ? currency : "INR",
                getProviderName(),
                devMode
        );
    }

    @Override
    public boolean verifyPayment(String providerPaymentId, String signature, String providerOrderId) {
        // In Development Mode, accept test verification calls.
        // In Production, real signatures from Razorpay/Stripe must be validated.
        if (devMode) {
            return providerPaymentId != null && !providerPaymentId.trim().isEmpty();
        }
        // Real provider verification logic goes here
        return false;
    }

    @Override
    public boolean refundPayment(String providerPaymentId, BigDecimal amount) {
        return devMode;
    }
}
