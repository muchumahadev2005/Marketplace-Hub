package com.olx.marketplace.config;

import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Slf4j
@Configuration
@Getter
public class RazorpayConfig {

    @Value("${razorpay.key.id}")
    private String keyId;

    @Value("${razorpay.key.secret}")
    private String keySecret;

    @Bean
    public RazorpayClient razorpayClient() {
        if (keyId == null || keyId.trim().isEmpty() || keySecret == null || keySecret.trim().isEmpty()) {
            throw new IllegalStateException("RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET environment variable is missing!");
        }
        try {
            log.info("Initializing RazorpayClient with Key ID: {}", keyId);
            return new RazorpayClient(keyId.trim(), keySecret.trim());
        } catch (RazorpayException e) {
            log.error("Failed to initialize RazorpayClient: {}", e.getMessage());
            throw new IllegalStateException("Could not initialize RazorpayClient", e);
        }
    }
}
