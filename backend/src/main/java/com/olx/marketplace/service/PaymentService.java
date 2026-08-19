package com.olx.marketplace.service;

import com.olx.marketplace.entity.Payment;
import com.olx.marketplace.entity.PaymentStatus;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.exception.ResourceNotFoundException;
import com.olx.marketplace.payment.PaymentProvider;
import com.olx.marketplace.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final PaymentProvider paymentProvider;

    @Transactional
    public Payment createPaymentOrder(User user, BigDecimal amount, String description) {
        PaymentProvider.PaymentOrderResult orderResult = paymentProvider.createOrder(user, amount, "INR", description);

        Payment payment = Payment.builder()
                .user(user)
                .amount(amount)
                .currency("INR")
                .status(PaymentStatus.PENDING)
                .provider(paymentProvider.getProviderName())
                .providerOrderId(orderResult.providerOrderId())
                .providerPaymentId(orderResult.providerPaymentId())
                .build();

        return paymentRepository.save(payment);
    }

    @Transactional
    public boolean verifyPayment(Payment payment, String providerPaymentId, String signature, boolean devModeSimulated) {
        if (payment.getStatus() == PaymentStatus.SUCCESS) {
            return true;
        }

        boolean isValid = paymentProvider.verifyPayment(
                providerPaymentId != null ? providerPaymentId : payment.getProviderPaymentId(),
                signature,
                payment.getProviderOrderId()
        );

        if (isValid || (paymentProvider.isDevMode() && devModeSimulated)) {
            payment.setStatus(PaymentStatus.SUCCESS);
            if (providerPaymentId != null) {
                payment.setProviderPaymentId(providerPaymentId);
            }
            paymentRepository.save(payment);
            return true;
        } else {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            return false;
        }
    }

    @Transactional(readOnly = true)
    public Payment getPaymentById(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found with id: " + id));
    }
}
