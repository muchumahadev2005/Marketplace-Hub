package com.olx.marketplace.dto.chat;

import com.olx.marketplace.dto.ad.AdResponse;
import com.olx.marketplace.dto.user.UserResponse;
import com.olx.marketplace.entity.ChatMessage;
import com.olx.marketplace.entity.ChatRoom;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomResponse {

    private Long id;
    private AdResponse ad;
    private UserResponse buyer;
    private UserResponse seller;
    private String lastMessage;
    private LocalDateTime lastMessageTime;
    private long unreadCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ChatRoomResponse fromEntity(ChatRoom room, Long currentUserId, long unreadCount) {
        if (room == null) return null;

        String lastMsgContent = "";
        LocalDateTime lastMsgTime = room.getUpdatedAt();

        if (room.getMessages() != null && !room.getMessages().isEmpty()) {
            ChatMessage lastMsg = room.getMessages().get(room.getMessages().size() - 1);
            lastMsgContent = lastMsg.getContent();
            lastMsgTime = lastMsg.getCreatedAt();
        }

        return ChatRoomResponse.builder()
                .id(room.getId())
                .ad(AdResponse.fromEntity(room.getAd()))
                .buyer(UserResponse.fromEntity(room.getBuyer()))
                .seller(UserResponse.fromEntity(room.getSeller()))
                .lastMessage(lastMsgContent)
                .lastMessageTime(lastMsgTime)
                .unreadCount(unreadCount)
                .createdAt(room.getCreatedAt())
                .updatedAt(room.getUpdatedAt())
                .build();
    }
}
