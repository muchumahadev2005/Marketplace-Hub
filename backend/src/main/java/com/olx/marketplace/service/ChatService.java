package com.olx.marketplace.service;

import com.olx.marketplace.dto.chat.ChatMessageResponse;
import com.olx.marketplace.dto.chat.ChatRoomResponse;
import com.olx.marketplace.dto.chat.SendMessageRequest;
import com.olx.marketplace.entity.Ad;
import com.olx.marketplace.entity.ChatMessage;
import com.olx.marketplace.entity.ChatRoom;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.exception.BadRequestException;
import com.olx.marketplace.exception.ResourceNotFoundException;
import com.olx.marketplace.repository.AdRepository;
import com.olx.marketplace.repository.ChatMessageRepository;
import com.olx.marketplace.repository.ChatRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final AdRepository adRepository;

    @Transactional
    public ChatRoomResponse getOrCreateChatRoom(User currentUser, Long adId) {
        Ad ad = adRepository.findById(adId)
                .orElseThrow(() -> new ResourceNotFoundException("Ad not found with id: " + adId));

        if (ad.getSeller().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You cannot start a chat for your own ad");
        }

        User buyer = currentUser;
        User seller = ad.getSeller();

        ChatRoom chatRoom = chatRoomRepository.findByAdIdAndBuyerIdAndSellerId(adId, buyer.getId(), seller.getId())
                .orElseGet(() -> {
                    ChatRoom newRoom = ChatRoom.builder()
                            .ad(ad)
                            .buyer(buyer)
                            .seller(seller)
                            .build();
                    return chatRoomRepository.save(newRoom);
                });

        long unread = chatMessageRepository.countByChatRoomIdAndSenderIdNotAndIsReadFalse(chatRoom.getId(), currentUser.getId());
        return ChatRoomResponse.fromEntity(chatRoom, currentUser.getId(), unread);
    }

    @Transactional(readOnly = true)
    public List<ChatRoomResponse> getMyChatRooms(User currentUser) {
        return chatRoomRepository.findByUserId(currentUser.getId())
                .stream()
                .map(room -> {
                    long unread = chatMessageRepository.countByChatRoomIdAndSenderIdNotAndIsReadFalse(room.getId(), currentUser.getId());
                    return ChatRoomResponse.fromEntity(room, currentUser.getId(), unread);
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public List<ChatMessageResponse> getMessages(User currentUser, Long chatRoomId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ResourceNotFoundException("Chat room not found with id: " + chatRoomId));

        if (!chatRoom.getBuyer().getId().equals(currentUser.getId()) && !chatRoom.getSeller().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You are not authorized to view messages in this chat room");
        }

        List<ChatMessage> messages = chatMessageRepository.findByChatRoomIdOrderByCreatedAtAsc(chatRoomId);

        // Mark messages from other user as read
        for (ChatMessage msg : messages) {
            if (!msg.getSender().getId().equals(currentUser.getId()) && !msg.isRead()) {
                msg.setRead(true);
                chatMessageRepository.save(msg);
            }
        }

        return messages.stream()
                .map(ChatMessageResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public ChatMessageResponse sendMessage(User currentUser, Long chatRoomId, SendMessageRequest request) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ResourceNotFoundException("Chat room not found with id: " + chatRoomId));

        if (!chatRoom.getBuyer().getId().equals(currentUser.getId()) && !chatRoom.getSeller().getId().equals(currentUser.getId())) {
            throw new BadRequestException("You are not authorized to send messages in this chat room");
        }

        ChatMessage message = ChatMessage.builder()
                .chatRoom(chatRoom)
                .sender(currentUser)
                .content(request.getContent().trim())
                .isRead(false)
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(message);

        // Touch chat room updatedAt
        chatRoomRepository.save(chatRoom);

        return ChatMessageResponse.fromEntity(savedMessage);
    }
}
