package com.olx.marketplace.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "ad_promotions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdPromotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ad_id", nullable = false)
    private Ad ad;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PromotionType promotionType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private PromotionStatus status = PromotionStatus.PENDING;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    private Integer durationDays;

    private LocalDateTime startedAt;

    private LocalDateTime expiresAt;

    private String paymentId;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
