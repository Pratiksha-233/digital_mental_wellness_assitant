package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.model.Message;
import com.wellness.wellness_assistant.service.ChatbotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/chatbot")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatbotController {
    
    private final ChatbotService chatbotService;
    
    @PostMapping("/message")
    public ResponseEntity<Message> sendMessage(@RequestBody Map<String, String> request) {
        try {
            String userMessage = request.get("message");
            if (userMessage == null || userMessage.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            
            Message response = chatbotService.processMessage(userMessage);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/greeting")
    public ResponseEntity<Message> getGreeting() {
        try {
            Message greeting = chatbotService.processMessage("hello");
            return ResponseEntity.ok(greeting);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
