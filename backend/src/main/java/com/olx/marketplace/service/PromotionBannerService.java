package com.olx.marketplace.service;

import com.olx.marketplace.dto.monetization.PromotionBannerResponse;
import com.olx.marketplace.repository.PromotionBannerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PromotionBannerService {

    private final PromotionBannerRepository promotionBannerRepository;

    @Transactional(readOnly = true)
    public List<PromotionBannerResponse> getActiveBanners() {
        return promotionBannerRepository.findByActiveTrue()
                .stream()
                .map(PromotionBannerResponse::fromEntity)
                .collect(Collectors.toList());
    }
}
