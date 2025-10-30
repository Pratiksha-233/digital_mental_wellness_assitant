package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.model.Message;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

@Service
public class ChatbotService {
    
    private final List<String> greetings = Arrays.asList(
        "Hello! I'm here to support your mental wellness journey. How are you feeling today?",
        "Hi there! Welcome to your mental wellness assistant. What's on your mind?",
        "Greetings! I'm here to help with your mental health and wellbeing. How can I assist you today?"
    );
    
    private final List<String> stressResponses = Arrays.asList(
        "I understand you're feeling stressed. Try taking a few deep breaths. Inhale for 4 counts, hold for 4, and exhale for 6. Would you like me to guide you through a quick relaxation exercise?",
        "Stress is a common experience. Let's work on some coping strategies. Have you tried the 5-4-3-2-1 grounding technique? Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.",
        "I hear that you're stressed. Remember that it's okay to feel this way. Consider taking a short break, going for a walk, or practicing mindfulness. What usually helps you relax?"
    );
    
    private final List<String> anxietyResponses = Arrays.asList(
        "Anxiety can feel overwhelming, but you're not alone. Try focusing on your breathing - breathe in slowly through your nose and out through your mouth. Is there something specific that's making you anxious?",
        "I understand you're experiencing anxiety. Remember that this feeling is temporary and will pass. Try to ground yourself in the present moment. What's one thing you can do right now to feel more calm?",
        "Anxiety is challenging, but you have the strength to get through this. Consider trying progressive muscle relaxation or calling a trusted friend. Would you like some specific coping techniques?"
    );
    
    private final List<String> sadnessResponses = Arrays.asList(
        "I'm sorry you're feeling sad. It's important to acknowledge these feelings rather than pushing them away. Sometimes sadness is our mind's way of processing difficult experiences. Is there anything specific that's contributing to these feelings?",
        "Feeling sad is a natural human emotion. Be gentle with yourself during this time. Consider doing something small that usually brings you comfort, or reach out to someone you trust. You don't have to go through this alone.",
        "I hear that you're feeling sad. These feelings are valid and it's okay to sit with them for a while. Sometimes self-care activities like taking a warm bath, listening to music, or writing can help process these emotions."
    );
    
    private final List<String> supportiveResponses = Arrays.asList(
        "You're taking a positive step by reaching out for support. That shows strength and self-awareness.",
        "Remember that seeking help is a sign of courage, not weakness. You're worth the investment in your mental health.",
        "It's normal to have ups and downs. What matters is that you're being proactive about your wellbeing.",
        "You have more strength than you realize. Taking care of your mental health is one of the best things you can do for yourself."
    );
    
    private final List<String> encouragements = Arrays.asList(
        "Remember: This too shall pass. You've overcome challenges before, and you can do it again.",
        "You are resilient, capable, and worthy of happiness and peace.",
        "Every small step you take toward better mental health matters. Be proud of yourself for trying.",
        "Your mental health journey is unique to you. There's no right or wrong way to heal, only your way."
    );
    
    public Message processMessage(String userMessage) {
        String response = generateResponse(userMessage.toLowerCase());
        
        Message message = new Message();
        message.setContent(response);
        message.setSender("Assistant");
        message.setTimestamp(LocalDateTime.now());
        
        return message;
    }
    
    private String generateResponse(String userMessage) {
        Random random = new Random();
        
        if (containsKeywords(userMessage, Arrays.asList("hello", "hi", "hey", "start"))) {
            return greetings.get(random.nextInt(greetings.size()));
        } else if (containsKeywords(userMessage, Arrays.asList("stress", "stressed", "overwhelmed", "pressure"))) {
            return stressResponses.get(random.nextInt(stressResponses.size()));
        } else if (containsKeywords(userMessage, Arrays.asList("anxious", "anxiety", "worry", "worried", "nervous", "panic"))) {
            return anxietyResponses.get(random.nextInt(anxietyResponses.size()));
        } else if (containsKeywords(userMessage, Arrays.asList("sad", "sadness", "depressed", "depression", "down", "low", "empty"))) {
            return sadnessResponses.get(random.nextInt(sadnessResponses.size()));
        } else if (containsKeywords(userMessage, Arrays.asList("help", "support", "advice", "guidance"))) {
            return supportiveResponses.get(random.nextInt(supportiveResponses.size()));
        } else if (containsKeywords(userMessage, Arrays.asList("thanks", "thank you", "grateful", "appreciate"))) {
            return "You're very welcome! I'm here whenever you need support. Remember to be kind to yourself.";
        } else if (containsKeywords(userMessage, Arrays.asList("crisis", "emergency", "suicide", "harm", "hurt myself"))) {
            return "I'm concerned about what you've shared. Please reach out for immediate help: National Suicide Prevention Lifeline: 988 or Crisis Text Line: Text HOME to 741741. You matter and there are people who want to help.";
        } else {
            // Default encouraging response
            return encouragements.get(random.nextInt(encouragements.size())) + 
                   " Is there something specific you'd like to talk about or get support with?";
        }
    }
    
    private boolean containsKeywords(String message, List<String> keywords) {
        return keywords.stream().anyMatch(message::contains);
    }
}
