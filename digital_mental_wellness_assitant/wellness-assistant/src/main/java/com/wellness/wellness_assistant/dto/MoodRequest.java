package com.wellness.wellness_assistant.dto;

import com.wellness.wellness_assistant.model.MoodEntry;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class MoodRequest {
    
    @NotNull(message = "Mood type is required")
    private MoodEntry.MoodType moodType;
    
    @Min(value = 1, message = "Mood intensity must be between 1 and 10")
    @Max(value = 10, message = "Mood intensity must be between 1 and 10")
    private Integer moodIntensity;
    
    private String moodNotes;
    
    private List<MoodEntry.MoodTrigger> triggers;
    
    private List<MoodEntry.Activity> activities;
    
    @Min(value = 0, message = "Sleep hours cannot be negative")
    @Max(value = 24, message = "Sleep hours cannot exceed 24")
    private Double sleepHours;
    
    @Min(value = 0, message = "Exercise minutes cannot be negative")
    private Integer exerciseMinutes;
}
