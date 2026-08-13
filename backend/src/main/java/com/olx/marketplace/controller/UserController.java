package com.olx.marketplace.controller;

import com.olx.marketplace.dto.common.ApiResponse;
import com.olx.marketplace.dto.user.UpdateUserRequest;
import com.olx.marketplace.dto.user.UserResponse;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(@AuthenticationPrincipal User currentUser) {
        UserResponse response = userService.getCurrentUserProfile(currentUser);
        return ResponseEntity.ok(ApiResponse.success("Current user profile retrieved successfully", response));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateCurrentUser(
            @AuthenticationPrincipal User currentUser,
            @RequestBody UpdateUserRequest request
    ) {
        UserResponse response = userService.updateProfile(currentUser, request);
        return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", response));
    }

    @DeleteMapping("/me")
    public ResponseEntity<ApiResponse<Void>> deleteCurrentUser(@AuthenticationPrincipal User currentUser) {
        userService.deactivateAccount(currentUser);
        return ResponseEntity.ok(ApiResponse.success("Account deactivated successfully", null));
    }
}
