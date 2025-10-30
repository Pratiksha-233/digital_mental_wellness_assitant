package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.dto.MeditationRequest;
import com.wellness.wellness_assistant.model.MeditationSession;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.repository.MeditationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MeditationService {
    
    private final MeditationRepository meditationRepository;
    
    public MeditationSession createMeditationSession(MeditationRequest request, User user) {
        MeditationSession session = new MeditationSession();
        session.setUser(user);
        session.setSessionName(request.getSessionName());
        session.setType(request.getType());
        session.setDurationMinutes(request.getDurationMinutes());
        session.setRating(request.getRating());
        session.setNotes(request.getNotes());
        session.setCompletedAt(LocalDateTime.now());
        
        return meditationRepository.save(session);
    }
    
    public List<MeditationSession> getUserMeditationSessions(User user) {
        return meditationRepository.findByUserOrderByCompletedAtDesc(user);
    }
    
    public List<MeditationSession> getUserMeditationSessionsInDateRange(User user, LocalDateTime startDate, LocalDateTime endDate) {
        return meditationRepository.findByUserAndCompletedAtBetweenOrderByCompletedAtDesc(user, startDate, endDate);
    }
    
    public Map<String, Object> getMeditationAnalytics(User user, int days) {
        LocalDateTime startDate = LocalDateTime.now().minusDays(days);
        LocalDateTime endDate = LocalDateTime.now();
        
        Map<String, Object> analytics = new HashMap<>();
        
        // Get total meditation time
        Long totalMinutes = meditationRepository.getTotalMeditationTime(user, startDate);
        analytics.put("totalMeditationMinutes", totalMinutes != null ? totalMinutes : 0L);
        
        // Get average rating
        Double averageRating = meditationRepository.getAverageRating(user);
        analytics.put("averageRating", averageRating != null ? averageRating : 0.0);
        
        // Get session count
        long sessionCount = meditationRepository.countByUserAndCompletedAtBetween(user, startDate, endDate);
        analytics.put("totalSessions", sessionCount);
        
        // Get sessions for detailed analysis
        List<MeditationSession> sessions = meditationRepository.findByUserAndCompletedAtBetweenOrderByCompletedAtDesc(user, startDate, endDate);
        
        // Calculate type distribution
        Map<String, Integer> typeDistribution = new HashMap<>();
        Map<String, Long> typeDuration = new HashMap<>();
        
        for (MeditationSession session : sessions) {
            String type = session.getType().toString();
            typeDistribution.put(type, typeDistribution.getOrDefault(type, 0) + 1);
            typeDuration.put(type, typeDuration.getOrDefault(type, 0L) + session.getDurationMinutes());
        }
        
        analytics.put("typeDistribution", typeDistribution);
        analytics.put("typeDuration", typeDuration);
        analytics.put("dateRange", Map.of("start", startDate, "end", endDate));
        
        // Calculate streak and consistency
        long currentStreak = calculateCurrentStreak(user);
        analytics.put("currentStreak", currentStreak);
        
        return analytics;
    }
    
    public MeditationSession getMeditationSessionById(Long id, User user) {
        return meditationRepository.findById(id)
            .filter(session -> session.getUser().getId().equals(user.getId()))
            .orElseThrow(() -> new RuntimeException("Meditation session not found"));
    }
    
    public void deleteMeditationSession(Long id, User user) {
        MeditationSession session = getMeditationSessionById(id, user);
        meditationRepository.delete(session);
    }
    
    private long calculateCurrentStreak(User user) {
        // Simple implementation - can be enhanced
        LocalDateTime today = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        long streak = 0;
        
        for (int i = 0; i < 30; i++) { // Check last 30 days
            LocalDateTime checkDate = today.minusDays(i);
            LocalDateTime nextDay = checkDate.plusDays(1);
            
            long sessionsOnDay = meditationRepository.countByUserAndCompletedAtBetween(user, checkDate, nextDay);
            
            if (sessionsOnDay > 0) {
                streak++;
            } else if (i == 0) {
                // If no session today, check if there was one yesterday
                continue;
            } else {
                break;
            }
        }
        
        return streak;
    }
}
