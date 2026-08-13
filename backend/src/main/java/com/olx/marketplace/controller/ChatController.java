package com.olx.marketplace.controller;

import com.olx.marketplace.dto.chat.ChatMessageResponse;
import com.olx.marketplace.dto.chat.ChatRoomResponse;
import com.olx.marketplace.dto.chat.SendMessageRequest;
import com.olx.marketplace.dto.common.ApiResponse;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chats")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/room")
    public ResponseEntity<ApiResponse<ChatRoomResponse>> getOrCreateChatRoom(
            @AuthenticationPrincipal User currentUser,
            @RequestParam Long adId
    ) {
        ChatRoomResponse room = chatService.getOrCreateChatRoom(currentUser, adId);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Chat room initialized", room));
    }

    @GetMapping("/rooms")
    public ResponseEntity<ApiResponse<List<ChatRoomResponse>>> getMyChatRooms(
            @AuthenticationPrincipal User currentUser
    ) {
        List<ChatRoomResponse> rooms = chatService.getMyChatRooms(currentUser);
        return ResponseEntity.ok(ApiResponse.success("Chat rooms retrieved successfully", rooms));
    }

    @GetMapping("/rooms/{roomId}/messages")
    public ResponseEntity<ApiResponse<List<ChatMessageResponse>>> getMessages(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long roomId
    ) {
        List<ChatMessageResponse> messages = chatService.getMessages(currentUser, roomId);
        return ResponseEntity.ok(ApiResponse.success("Messages retrieved successfully", messages));
    }

    @PostMapping("/rooms/{roomId}/messages")
    public ResponseEntity<ApiResponse<ChatMessageResponse>> sendMessage(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long roomId,
            @Valid @RequestBody SendMessageRequest request
    ) {
        ChatMessageResponse response = chatService.sendMessage(currentUser, roomId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Message sent successfully", response));
    }
}
