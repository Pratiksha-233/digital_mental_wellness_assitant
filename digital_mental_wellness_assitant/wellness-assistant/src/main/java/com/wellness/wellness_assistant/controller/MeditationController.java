package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.dto.MeditationRequest;
import com.wellness.wellness_assistant.model.MeditationSession;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.service.AuthService;
import com.wellness.wellness_assistant.service.MeditationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/meditation")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MeditationController {
    
    private final MeditationService meditationService;
    private final AuthService authService;
    
    @PostMapping
    public ResponseEntity<MeditationSession> createMeditationSession(
            @Valid @RequestBody MeditationRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            MeditationSession session = meditationService.createMeditationSession(request, user);
            return ResponseEntity.ok(session);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping
    public ResponseEntity<List<MeditationSession>> getUserMeditationSessions(
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            List<MeditationSession> sessions = meditationService.getUserMeditationSessions(user);
            return ResponseEntity.ok(sessions);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/date-range")
    public ResponseEntity<List<MeditationSession>> getMeditationSessionsInDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            List<MeditationSession> sessions = meditationService.getUserMeditationSessionsInDateRange(user, startDate, endDate);
            return ResponseEntity.ok(sessions);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/analytics")
    public ResponseEntity<Map<String, Object>> getMeditationAnalytics(
            @RequestParam(defaultValue = "30") int days,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            Map<String, Object> analytics = meditationService.getMeditationAnalytics(user, days);
            return ResponseEntity.ok(analytics);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<MeditationSession> getMeditationSession(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            MeditationSession session = meditationService.getMeditationSessionById(id, user);
            return ResponseEntity.ok(session);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMeditationSession(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            meditationService.deleteMeditationSession(id, user);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
