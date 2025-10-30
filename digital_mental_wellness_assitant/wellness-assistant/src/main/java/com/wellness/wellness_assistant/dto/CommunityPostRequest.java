package com.wellness.wellness_assistant.dto;

import com.wellness.wellness_assistant.model.CommunityPost;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CommunityPostRequest {
    
    @NotBlank(message = "Title is required")
    private String title;
    
    @NotBlank(message = "Content is required")
    private String content;
    
    @NotNull(message = "Category is required")
    private CommunityPost.Category category;
    
    private Boolean isAnonymous = false;
}