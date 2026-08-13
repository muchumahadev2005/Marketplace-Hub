package com.olx.marketplace.service;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.entity.Ad;
import com.olx.marketplace.entity.Favorite;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.exception.ResourceNotFoundException;
import com.olx.marketplace.repository.AdRepository;
import com.olx.marketplace.repository.FavoriteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final AdRepository adRepository;

    @Transactional
    public void addFavorite(User currentUser, Long adId) {
        Ad ad = adRepository.findById(adId)
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + adId));

        if (!favoriteRepository.existsByUserIdAndAdId(currentUser.getId(), adId)) {
            Favorite favorite = Favorite.builder()
                    .user(currentUser)
                    .ad(ad)
                    .build();
            favoriteRepository.save(favorite);
        }
    }

    @Transactional
    public void removeFavorite(User currentUser, Long adId) {
        if (!adRepository.existsById(adId)) {
            throw new ResourceNotFoundException("Ad not found with id: " + adId);
        }
        favoriteRepository.deleteByUserIdAndAdId(currentUser.getId(), adId);
    }

    @Transactional(readOnly = true)
    public List<AdResponse> getMyFavorites(User currentUser) {
        return favoriteRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(fav -> AdResponse.fromEntity(fav.getAd(), true))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public boolean isFavorite(User currentUser, Long adId) {
        if (currentUser == null) return false;
        return favoriteRepository.existsByUserIdAndAdId(currentUser.getId(), adId);
    }
}
