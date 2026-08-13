package com.olx.marketplace.repository;

import com.olx.marketplace.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    boolean existsByUserIdAndAdId(Long userId, Long adId);

    Optional<Favorite> findByUserIdAndAdId(Long userId, Long adId);

    void deleteByUserIdAndAdId(Long userId, Long adId);

    List<Favorite> findByUserIdOrderByCreatedAtDesc(Long userId);
}
