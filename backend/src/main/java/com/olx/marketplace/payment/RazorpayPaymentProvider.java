package com.olx.marketplace.payment;

import com.olx.marketplace.config.RazorpayConfig;
import com.olx.marketplace.entity.User;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Slf4j
@Component
@Primary
@RequiredArgsConstructor
public class RazorpayPaymentProvider implements PaymentProvider {

    private final RazorpayClient razorpayClient;
    private final RazorpayConfig razorpayConfig;

    @Override
    public String getProviderName() {
        return "RAZORPAY";
    }

    @Override
    public boolean isDevMode() {
        return razorpayConfig.getKeyId() != null && razorpayConfig.getKeyId().startsWith("rzp_test_");
    }

    @Override
    public PaymentOrderResult createOrder(User user, BigDecimal amount, String currency, String description) {
        try {
            // Convert INR amount to smallest currency unit (paise)
            long amountInPaise = amount.setScale(2, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"))
                    .longValueExact();

            JSONObject orderRequest = new JSONObject();
            orderRequest.put("amount", amountInPaise);
            orderRequest.put("currency", currency != null ? currency : "INR");
            orderRequest.put("receipt", "rcpt_" + System.currentTimeMillis());

            JSONObject notes = new JSONObject();
            notes.put("user_id", user.getId().toString());
            notes.put("user_email", user.getEmail());
            notes.put("description", description != null ? description : "OLX Marketplace Promotion");
            orderRequest.put("notes", notes);

            log.info("Creating Razorpay Order for amount: {} paise ({})", amountInPaise, currency);
            Order order = razorpayClient.orders.create(orderRequest);

            String providerOrderId = order.get("id");
            String providerPaymentId = null; // Generated when buyer pays on client

            return new PaymentOrderResult(
                    providerOrderId,
                    providerPaymentId,
                    amount,
                    currency != null ? currency : "INR",
                    getProviderName(),
                    isDevMode()
            );
        } catch (RazorpayException e) {
            log.error("Razorpay order creation failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to create Razorpay Order: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean verifyPayment(String providerPaymentId, String signature, String providerOrderId) {
        if (providerPaymentId == null || signature == null || providerOrderId == null) {
            return false;
        }
        try {
            JSONObject options = new JSONObject();
            options.put("razorpay_order_id", providerOrderId);
            options.put("razorpay_payment_id", providerPaymentId);
            options.put("razorpay_signature", signature);

            return Utils.verifyPaymentSignature(options, razorpayConfig.getKeySecret());
        } catch (RazorpayException e) {
            log.error("Razorpay payment signature verification failed: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public boolean refundPayment(String providerPaymentId, BigDecimal amount) {
        // Refund abstraction interface for future provider implementation
        return false;
    }
}
