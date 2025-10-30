package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.dto.AuthResponse;
import com.wellness.wellness_assistant.dto.LoginRequest;
import com.wellness.wellness_assistant.dto.RegisterRequest;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final AuthService authService;
    
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/me")
    public ResponseEntity<User> getCurrentUser(@AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
