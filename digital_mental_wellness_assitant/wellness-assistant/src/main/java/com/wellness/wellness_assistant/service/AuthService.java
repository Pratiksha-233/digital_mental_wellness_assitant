package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.dto.AuthResponse;
import com.wellness.wellness_assistant.dto.LoginRequest;
import com.wellness.wellness_assistant.dto.RegisterRequest;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.repository.UserRepository;
import com.wellness.wellness_assistant.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setGender(request.getGender());
        user.setEmergencyContact(request.getEmergencyContact());
        user.setEmergencyPhone(request.getEmergencyPhone());
        
        User savedUser = userRepository.save(user);
        String token = jwtUtil.generateToken(savedUser.getEmail());
        
        return new AuthResponse(token, savedUser.getId(), savedUser.getEmail(), 
                               savedUser.getFirstName(), savedUser.getLastName());
    }
    
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        
        User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        String token = jwtUtil.generateToken(user.getEmail());
        
        return new AuthResponse(token, user.getId(), user.getEmail(), 
                               user.getFirstName(), user.getLastName());
    }
    
    public User getCurrentUser(String email) {
        return userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
