package com.wellness.wellness_assistant.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Message {
    
    private String content;
    private String sender;
    private LocalDateTime timestamp;
}
