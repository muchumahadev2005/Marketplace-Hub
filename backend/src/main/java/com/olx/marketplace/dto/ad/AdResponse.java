package com.olx.marketplace.dto.ad;

import com.olx.marketplace.dto.user.UserResponse;
import com.olx.marketplace.entity.Ad;
import com.olx.marketplace.entity.AdCondition;
import com.olx.marketplace.entity.AdImage;
import com.olx.marketplace.entity.AdStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdResponse {

    private Long id;
    private String title;
    private String description;
    private BigDecimal price;
    private String formattedPrice;
    private AdCondition condition;
    private Long categoryId;
    private String categoryName;
    private Long subcategoryId;
    private String subcategoryName;
    private String brand;
    private String model;
    private String reasonForSelling;
    private String additionalDetails;
    private String location;
    private Double latitude;
    private Double longitude;
    private AdStatus status;
    private boolean isFeatured;
    private LocalDateTime featuredUntil;
    private String promotionType;
    private Integer views;
    private UserResponse seller;
    @Builder.Default
    private List<String> images = new ArrayList<>();
    private String imageUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isFavorite;

    public static AdResponse fromEntity(Ad ad) {
        return fromEntity(ad, false);
    }

    public static AdResponse fromEntity(Ad ad, boolean isFavorite) {
        if (ad == null) return null;

        List<String> imageList = new ArrayList<>();
        if (ad.getImages() != null && !ad.getImages().isEmpty()) {
            imageList = ad.getImages().stream()
                    .map(AdImage::getImageUrl)
                    .collect(Collectors.toList());
        }

        String mainImage = !imageList.isEmpty() ? imageList.get(0) : "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&q=80";

        return AdResponse.builder()
                .id(ad.getId())
                .title(ad.getTitle())
                .description(ad.getDescription())
                .price(ad.getPrice())
                .formattedPrice("₹" + (ad.getPrice() != null ? ad.getPrice().toPlainString() : "0"))
                .condition(ad.getCondition())
                .categoryId(ad.getCategory() != null ? ad.getCategory().getId() : null)
                .categoryName(ad.getCategory() != null ? ad.getCategory().getName() : null)
                .subcategoryId(ad.getSubcategory() != null ? ad.getSubcategory().getId() : null)
                .subcategoryName(ad.getSubcategory() != null ? ad.getSubcategory().getName() : null)
                .brand(ad.getBrand())
                .model(ad.getModel())
                .reasonForSelling(ad.getReasonForSelling())
                .additionalDetails(ad.getAdditionalDetails())
                .location(ad.getLocation())
                .latitude(ad.getLatitude())
                .longitude(ad.getLongitude())
                .status(ad.getStatus())
                .isFeatured(ad.isFeatured())
                .featuredUntil(ad.getFeaturedUntil())
                .promotionType(ad.getPromotionType())
                .views(ad.getViews())
                .seller(UserResponse.fromEntity(ad.getSeller()))
                .images(imageList)
                .imageUrl(mainImage)
                .createdAt(ad.getCreatedAt())
                .updatedAt(ad.getUpdatedAt())
                .isFavorite(isFavorite)
                .build();
    }
}
