package com.olx.marketplace.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.olx.marketplace.dto.auth.AuthResponse;
import com.olx.marketplace.dto.auth.GoogleLoginRequest;
import com.olx.marketplace.dto.auth.LoginRequest;
import com.olx.marketplace.dto.auth.RegisterRequest;
import com.olx.marketplace.dto.user.UserResponse;
import com.olx.marketplace.entity.Role;
import com.olx.marketplace.entity.User;
import com.olx.marketplace.exception.BadRequestException;
import com.olx.marketplace.repository.UserRepository;
import com.olx.marketplace.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Value("${google.client.id}")
    private String googleClientId;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail().trim().toLowerCase())) {
            throw new BadRequestException("An account with this email already exists");
        }

        User user = User.builder()
                .name(request.getName().trim())
                .email(request.getEmail().trim().toLowerCase())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone() != null ? request.getPhone().trim() : null)
                .role(Role.USER)
                .active(true)
                .build();

        User savedUser = userRepository.save(user);
        String token = jwtService.generateToken(savedUser);

        return AuthResponse.builder()
                .token(token)
                .user(UserResponse.fromEntity(savedUser))
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail().trim().toLowerCase(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByEmail(request.getEmail().trim().toLowerCase())
                .orElseThrow(() -> new BadRequestException("Invalid email or password"));

        String token = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(token)
                .user(UserResponse.fromEntity(user))
                .build();
    }

    @Transactional
    public AuthResponse googleLogin(GoogleLoginRequest request) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance()
            )
            .setAudience(Collections.singletonList(googleClientId))
            .build();

            GoogleIdToken idToken = verifier.verify(request.getIdToken());
            String email;
            String name;
            String picture = null;

            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                email = payload.getEmail().toLowerCase();
                name = (String) payload.get("name");
                picture = (String) payload.get("picture");
                if (name == null || name.trim().isEmpty()) {
                    name = email.split("@")[0];
                }
            } else {
                throw new BadRequestException("Invalid Google ID token");
            }

            String finalName = name;
            String finalPicture = picture;

            User user = userRepository.findByEmail(email)
                    .orElseGet(() -> {
                        User newUser = User.builder()
                                .name(finalName)
                                .email(email)
                                .password(passwordEncoder.encode(UUID.randomUUID().toString()))
                                .profileImage(finalPicture)
                                .role(Role.USER)
                                .active(true)
                                .build();
                        return userRepository.save(newUser);
                    });

            String token = jwtService.generateToken(user);

            return AuthResponse.builder()
                    .token(token)
                    .user(UserResponse.fromEntity(user))
                    .build();

        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            throw new BadRequestException("Failed to authenticate with Google: " + e.getMessage());
        }
    }
}
