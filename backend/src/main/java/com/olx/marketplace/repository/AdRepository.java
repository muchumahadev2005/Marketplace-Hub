package com.olx.marketplace.repository;

import com.olx.marketplace.entity.Ad;
import com.olx.marketplace.entity.AdCondition;
import com.olx.marketplace.entity.AdStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface AdRepository extends JpaRepository<Ad, Long> {

    Page<Ad> findByStatusOrderByCreatedAtDesc(AdStatus status, Pageable pageable);

    List<Ad> findBySellerIdAndStatusNotOrderByCreatedAtDesc(Long sellerId, AdStatus status);

    List<Ad> findBySellerIdAndStatusOrderByCreatedAtDesc(Long sellerId, AdStatus status);

    Page<Ad> findByCategoryIdAndStatusOrderByCreatedAtDesc(Long categoryId, AdStatus status, Pageable pageable);

    Page<Ad> findBySubcategoryIdAndStatusOrderByCreatedAtDesc(Long subcategoryId, AdStatus status, Pageable pageable);

    List<Ad> findByIsFeaturedTrueAndStatusOrderByCreatedAtDesc(AdStatus status);

    @Query("SELECT a FROM Ad a WHERE a.status = :status AND " +
            "(:keyword IS NULL OR LOWER(a.title) LIKE :keyword OR LOWER(a.description) LIKE :keyword) AND " +
            "(:categoryId IS NULL OR a.category.id = :categoryId) AND " +
            "(:subcategoryId IS NULL OR a.subcategory.id = :subcategoryId) AND " +
            "(:minPrice IS NULL OR a.price >= :minPrice) AND " +
            "(:maxPrice IS NULL OR a.price <= :maxPrice) AND " +
            "(:condition IS NULL OR a.condition = :condition) AND " +
            "(:location IS NULL OR LOWER(a.location) LIKE :location) " +
            "ORDER BY a.isFeatured DESC, a.createdAt DESC")
    Page<Ad> searchAds(
            @Param("status") AdStatus status,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("subcategoryId") Long subcategoryId,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice,
            @Param("condition") AdCondition condition,
            @Param("location") String location,
            Pageable pageable
    );
}
