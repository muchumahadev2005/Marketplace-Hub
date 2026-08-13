package com.olx.marketplace.dto.home;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.dto.category.CategoryResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HomeScreenResponse {

    @Builder.Default
    private List<CategoryResponse> categories = new ArrayList<>();

    @Builder.Default
    private List<AdResponse> featuredAds = new ArrayList<>();

    @Builder.Default
    private List<AdResponse> recentAds = new ArrayList<>();
}
