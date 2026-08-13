package com.olx.marketplace.service;

import com.olx.marketplace.dto.user.UpdateUserRequest;
import com.olx.marketplace.dto.user.UserResponse;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserResponse getCurrentUserProfile(User user) {
        return UserResponse.fromEntity(user);
    }

    @Transactional
    public UserResponse updateProfile(User currentUser, UpdateUserRequest request) {
        if (request.getName() != null && !request.getName().trim().isEmpty()) {
            currentUser.setName(request.getName().trim());
        }
        if (request.getPhone() != null) {
            currentUser.setPhone(request.getPhone().trim());
        }
        if (request.getLocation() != null) {
            currentUser.setLocation(request.getLocation().trim());
        }
        if (request.getProfileImage() != null) {
            currentUser.setProfileImage(request.getProfileImage().trim());
        }

        User updatedUser = userRepository.save(currentUser);
        return UserResponse.fromEntity(updatedUser);
    }

    @Transactional
    public void deactivateAccount(User currentUser) {
        currentUser.setActive(false);
        userRepository.save(currentUser);
    }
}
