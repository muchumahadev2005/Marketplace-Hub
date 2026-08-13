package com.olx.marketplace.repository;

import com.olx.marketplace.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    Optional<ChatRoom> findByAdIdAndBuyerIdAndSellerId(Long adId, Long buyerId, Long sellerId);

    @Query("SELECT c FROM ChatRoom c WHERE c.buyer.id = :userId OR c.seller.id = :userId ORDER BY c.updatedAt DESC")
    List<ChatRoom> findByUserId(@Param("userId") Long userId);
}
