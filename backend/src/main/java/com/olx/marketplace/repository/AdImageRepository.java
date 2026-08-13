package com.olx.marketplace.repository;

import com.olx.marketplace.entity.AdImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AdImageRepository extends JpaRepository<AdImage, Long> {
    List<AdImage> findByAdIdOrderByDisplayOrderAsc(Long adId);
}
