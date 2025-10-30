package com.wellness.wellness_assistant.dto;

import com.wellness.wellness_assistant.model.MeditationSession;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MeditationRequest {
    
    @NotBlank(message = "Session name is required")
    private String sessionName;
    
    @NotNull(message = "Meditation type is required")
    private MeditationSession.MeditationType type;
    
    @Min(value = 1, message = "Duration must be at least 1 minute")
    @Max(value = 180, message = "Duration cannot exceed 180 minutes")
    private Integer durationMinutes;
    
    @Min(value = 1, message = "Rating must be between 1 and 5")
    @Max(value = 5, message = "Rating must be between 1 and 5")
    private Integer rating;
    
    private String notes;
}