package com.olx.marketplace.service;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.dto.ad.CreateAdRequest;
import com.olx.marketplace.entity.*;
import com.olx.marketplace.exception.BadRequestException;
import com.olx.marketplace.exception.ResourceNotFoundException;
import com.olx.marketplace.repository.AdRepository;
import com.olx.marketplace.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdService {

    private final AdRepository adRepository;
    private final CategoryRepository categoryRepository;
    private final SubscriptionService subscriptionService;

    @Transactional
    public AdResponse createAd(User seller, CreateAdRequest request) {
        // Enforce Seller Plan Active Ad Limit
        int activeAdsCount = adRepository.findBySellerIdAndStatusOrderByCreatedAtDesc(seller.getId(), AdStatus.ACTIVE).size();
        int adLimit = subscriptionService.getAdLimitForPlan(seller.getSellerType());

        if (activeAdsCount >= adLimit) {
            throw new BadRequestException("Active ad limit reached (" + activeAdsCount + "/" + adLimit + ") for your " +
                    (seller.getSellerType() != null ? seller.getSellerType() : "FREE") + " plan. Upgrade your plan to post more ads!");
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with id: " + request.getCategoryId()));

        Category subcategory = null;
        if (request.getSubcategoryId() != null) {
            subcategory = categoryRepository.findById(request.getSubcategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Subcategory not found with id: " + request.getSubcategoryId()));
        }

        Ad ad = Ad.builder()
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .price(request.getPrice())
                .condition(request.getCondition())
                .seller(seller)
                .category(category)
                .subcategory(subcategory)
                .brand(request.getBrand() != null ? request.getBrand().trim() : null)
                .model(request.getModel() != null ? request.getModel().trim() : null)
                .reasonForSelling(request.getReasonForSelling() != null ? request.getReasonForSelling().trim() : null)
                .additionalDetails(request.getAdditionalDetails() != null ? request.getAdditionalDetails().trim() : null)
                .location(request.getLocation().trim())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .status(AdStatus.ACTIVE)
                .isFeatured(false)
                .views(0)
                .build();

        if (request.getImageUrls() != null && !request.getImageUrls().isEmpty()) {
            int order = 0;
            for (String url : request.getImageUrls()) {
                if (url != null && !url.trim().isEmpty()) {
                    AdImage image = AdImage.builder()
                            .imageUrl(url.trim())
                            .displayOrder(order++)
                            .build();
                    ad.addImage(image);
                }
            }
        }

        Ad savedAd = adRepository.save(ad);
        return AdResponse.fromEntity(savedAd);
    }

    @Transactional
    public AdResponse getAdById(Long id) {
        Ad ad = adRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + id));

        if (ad.getStatus() == AdStatus.DELETED) {
            throw new ResourceNotFoundException("Ad not found with id: " + id);
        }

        // Increment view count
        ad.setViews(ad.getViews() + 1);
        adRepository.save(ad);

        return AdResponse.fromEntity(ad);
    }

    @Transactional(readOnly = true)
    public Page<AdResponse> getActiveAds(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return adRepository.findByStatusOrderByCreatedAtDesc(AdStatus.ACTIVE, pageable)
                .map(AdResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public List<AdResponse> getMyAds(User seller) {
        return adRepository.findBySellerIdAndStatusNotOrderByCreatedAtDesc(seller.getId(), AdStatus.DELETED)
                .stream()
                .map(AdResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<AdResponse> searchAds(
            String keyword,
            Long categoryId,
            Long subcategoryId,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            AdCondition condition,
            String location,
            int page,
            int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        String keywordPattern = (keyword != null && !keyword.trim().isEmpty())
                ? "%" + keyword.trim().toLowerCase() + "%"
                : null;
        String locationPattern = (location != null && !location.trim().isEmpty())
                ? "%" + location.trim().toLowerCase() + "%"
                : null;

        return adRepository.searchAds(
                AdStatus.ACTIVE,
                keywordPattern,
                categoryId,
                subcategoryId,
                minPrice,
                maxPrice,
                condition,
                locationPattern,
                pageable
        ).map(AdResponse::fromEntity);
    }

    @Transactional
    public AdResponse updateAd(Long id, User currentUser, CreateAdRequest request) {
        Ad ad = adRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + id));

        if (!ad.getSeller().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You are not authorized to update this ad");
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with id: " + request.getCategoryId()));

        Category subcategory = null;
        if (request.getSubcategoryId() != null) {
            subcategory = categoryRepository.findById(request.getSubcategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Subcategory not found with id: " + request.getSubcategoryId()));
        }

        ad.setTitle(request.getTitle().trim());
        ad.setDescription(request.getDescription().trim());
        ad.setPrice(request.getPrice());
        ad.setCondition(request.getCondition());
        ad.setCategory(category);
        ad.setSubcategory(subcategory);
        ad.setBrand(request.getBrand() != null ? request.getBrand().trim() : null);
        ad.setModel(request.getModel() != null ? request.getModel().trim() : null);
        ad.setReasonForSelling(request.getReasonForSelling() != null ? request.getReasonForSelling().trim() : null);
        ad.setAdditionalDetails(request.getAdditionalDetails() != null ? request.getAdditionalDetails().trim() : null);
        ad.setLocation(request.getLocation().trim());

        Ad updatedAd = adRepository.save(ad);
        return AdResponse.fromEntity(updatedAd);
    }

    @Transactional
    public void markAsSold(Long id, User currentUser) {
        Ad ad = adRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + id));

        if (!ad.getSeller().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You are not authorized to modify this ad");
        }

        ad.setStatus(AdStatus.SOLD);
        adRepository.save(ad);
    }

    @Transactional
    public void deleteAd(Long id, User currentUser) {
        Ad ad = adRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + id));

        boolean isAdmin = currentUser.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (!ad.getSeller().getId().equals(currentUser.getId()) && !isAdmin) {
            throw new BadRequestException("You are not authorized to delete this ad");
        }

        ad.setStatus(AdStatus.DELETED);
        adRepository.save(ad);
    }
}
