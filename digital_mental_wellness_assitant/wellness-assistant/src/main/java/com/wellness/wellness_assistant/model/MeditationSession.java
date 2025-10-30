package com.wellness.wellness_assistant.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "meditation_sessions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MeditationSession {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "session_name", nullable = false)
    private String sessionName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MeditationType type;
    
    @Column(name = "duration_minutes", nullable = false)
    private Integer durationMinutes;
    
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
    
    @Column(name = "rating")
    private Integer rating; // 1-5 scale
    
    @Column(name = "notes", length = 500)
    private String notes;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    public enum MeditationType {
        MINDFULNESS, BREATHING, BODY_SCAN, LOVING_KINDNESS, VISUALIZATION, MANTRA, WALKING
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}