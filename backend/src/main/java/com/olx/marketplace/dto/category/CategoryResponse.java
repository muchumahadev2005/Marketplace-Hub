package com.olx.marketplace.dto.category;

import com.olx.marketplace.entity.Category;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryResponse {

    private Long id;
    private String name;
    private String description;
    private String imageUrl;
    private String icon;
    private Long parentCategoryId;
    private Integer displayOrder;
    @Builder.Default
    private List<CategoryResponse> subcategories = new ArrayList<>();

    public static CategoryResponse fromEntity(Category category) {
        if (category == null) return null;

        List<CategoryResponse> subDtos = new ArrayList<>();
        if (category.getSubcategories() != null && !category.getSubcategories().isEmpty()) {
            subDtos = category.getSubcategories().stream()
                    .map(CategoryResponse::fromEntity)
                    .collect(Collectors.toList());
        }

        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .imageUrl(category.getImageUrl())
                .icon(category.getIcon())
                .parentCategoryId(category.getParentCategory() != null ? category.getParentCategory().getId() : null)
                .displayOrder(category.getDisplayOrder())
                .subcategories(subDtos)
                .build();
    }
}
