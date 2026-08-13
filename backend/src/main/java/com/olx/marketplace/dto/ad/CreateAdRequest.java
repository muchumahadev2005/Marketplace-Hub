package com.olx.marketplace.dto.ad;

import com.olx.marketplace.entity.AdCondition;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateAdRequest {

    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", inclusive = true, message = "Price cannot be negative")
    private BigDecimal price;

    @NotNull(message = "Condition is required")
    private AdCondition condition;

    @NotNull(message = "Category is required")
    private Long categoryId;

    private Long subcategoryId;

    private String brand;

    private String model;

    private String reasonForSelling;

    private String additionalDetails;

    @NotBlank(message = "Location is required")
    private String location;

    private Double latitude;

    private Double longitude;

    @Builder.Default
    private List<String> imageUrls = new ArrayList<>();
}
