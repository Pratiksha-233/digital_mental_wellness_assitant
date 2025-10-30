package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.dto.MoodRequest;
import com.wellness.wellness_assistant.model.MoodEntry;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.service.AuthService;
import com.wellness.wellness_assistant.service.MoodService;
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
@RequestMapping("/api/mood")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MoodController {
    
    private final MoodService moodService;
    private final AuthService authService;
    
    @PostMapping
    public ResponseEntity<MoodEntry> createMoodEntry(
            @Valid @RequestBody MoodRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            MoodEntry moodEntry = moodService.createMoodEntry(request, user);
            return ResponseEntity.ok(moodEntry);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping
    public ResponseEntity<List<MoodEntry>> getUserMoodEntries(
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            List<MoodEntry> entries = moodService.getUserMoodEntries(user);
            return ResponseEntity.ok(entries);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/date-range")
    public ResponseEntity<List<MoodEntry>> getMoodEntriesInDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            List<MoodEntry> entries = moodService.getUserMoodEntriesInDateRange(user, startDate, endDate);
            return ResponseEntity.ok(entries);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/recent")
    public ResponseEntity<List<MoodEntry>> getRecentMoodEntries(
            @RequestParam(defaultValue = "7") int days,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            List<MoodEntry> entries = moodService.getRecentMoodEntries(user, days);
            return ResponseEntity.ok(entries);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/analytics")
    public ResponseEntity<Map<String, Object>> getMoodAnalytics(
            @RequestParam(defaultValue = "30") int days,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            Map<String, Object> analytics = moodService.getMoodAnalytics(user, days);
            return ResponseEntity.ok(analytics);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<MoodEntry> getMoodEntry(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            MoodEntry entry = moodService.getMoodEntryById(id, user);
            return ResponseEntity.ok(entry);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMoodEntry(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            moodService.deleteMoodEntry(id, user);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
