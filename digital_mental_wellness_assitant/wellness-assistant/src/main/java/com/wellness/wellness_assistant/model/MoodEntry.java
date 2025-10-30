package com.wellness.wellness_assistant.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "mood_entries")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MoodEntry {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MoodType moodType;
    
    @Column(name = "mood_intensity")
    private Integer moodIntensity; // 1-10 scale
    
    @Column(name = "mood_notes", length = 500)
    private String moodNotes;
    
    @ElementCollection
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "mood_triggers", joinColumns = @JoinColumn(name = "mood_entry_id"))
    @Column(name = "trigger")
    private List<MoodTrigger> triggers;
    
    @ElementCollection
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "mood_activities", joinColumns = @JoinColumn(name = "mood_entry_id"))
    @Column(name = "activity")
    private List<Activity> activities;
    
    @Column(name = "sleep_hours")
    private Double sleepHours;
    
    @Column(name = "exercise_minutes")
    private Integer exerciseMinutes;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    public enum MoodType {
        VERY_HAPPY, HAPPY, NEUTRAL, SAD, VERY_SAD, ANXIOUS, STRESSED, CALM, EXCITED, ANGRY
    }
    
    public enum MoodTrigger {
        WORK_STRESS, RELATIONSHIP, FAMILY, HEALTH, MONEY, WEATHER, SLEEP, EXERCISE, SOCIAL, OTHER
    }
    
    public enum Activity {
        MEDITATION, EXERCISE, READING, MUSIC, SOCIALIZING, WORK, HOBBY, SLEEP, EATING, OUTDOOR
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
