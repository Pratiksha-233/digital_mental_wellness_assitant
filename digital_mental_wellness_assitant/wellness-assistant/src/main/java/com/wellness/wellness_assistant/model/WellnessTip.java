package com.wellness.wellness_assistant.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "wellness_tips")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WellnessTip {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String title;
    
    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(name = "read_time_minutes")
    private Integer readTimeMinutes;
    
    @Column(name = "is_featured")
    private Boolean isFeatured = false;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user; // For saved tips
    
    public enum Category {
        STRESS_MANAGEMENT, ANXIETY_RELIEF, DEPRESSION_SUPPORT, SLEEP_HYGIENE, 
        MINDFULNESS, EXERCISE, NUTRITION, RELATIONSHIPS, WORK_LIFE_BALANCE, SELF_CARE
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}