package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.dto.MoodRequest;
import com.wellness.wellness_assistant.model.MoodEntry;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.repository.MoodRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MoodService {
    
    private final MoodRepository moodRepository;
    
    public MoodEntry createMoodEntry(MoodRequest request, User user) {
        MoodEntry moodEntry = new MoodEntry();
        moodEntry.setUser(user);
        moodEntry.setMoodType(request.getMoodType());
        moodEntry.setMoodIntensity(request.getMoodIntensity());
        moodEntry.setMoodNotes(request.getMoodNotes());
        moodEntry.setTriggers(request.getTriggers());
        moodEntry.setActivities(request.getActivities());
        moodEntry.setSleepHours(request.getSleepHours());
        moodEntry.setExerciseMinutes(request.getExerciseMinutes());
        
        return moodRepository.save(moodEntry);
    }
    
    public List<MoodEntry> getUserMoodEntries(User user) {
        return moodRepository.findByUserOrderByCreatedAtDesc(user);
    }
    
    public List<MoodEntry> getUserMoodEntriesInDateRange(User user, LocalDateTime startDate, LocalDateTime endDate) {
        return moodRepository.findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);
    }
    
    public List<MoodEntry> getRecentMoodEntries(User user, int days) {
        LocalDateTime startDate = LocalDateTime.now().minusDays(days);
        return moodRepository.findRecentMoodEntries(user, startDate);
    }
    
    public Map<String, Object> getMoodAnalytics(User user, int days) {
        LocalDateTime startDate = LocalDateTime.now().minusDays(days);
        LocalDateTime endDate = LocalDateTime.now();
        
        Map<String, Object> analytics = new HashMap<>();
        
        // Get average mood intensity
        Double averageMood = moodRepository.getAverageMoodIntensity(user, startDate);
        analytics.put("averageMoodIntensity", averageMood != null ? averageMood : 0.0);
        
        // Get total entries count
        long totalEntries = moodRepository.countByUserAndCreatedAtBetween(user, startDate, endDate);
        analytics.put("totalEntries", totalEntries);
        
        // Get mood entries for analysis
        List<MoodEntry> entries = moodRepository.findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(user, startDate, endDate);
        
        // Calculate mood distribution
        Map<String, Integer> moodDistribution = new HashMap<>();
        Map<String, Integer> triggerAnalysis = new HashMap<>();
        
        for (MoodEntry entry : entries) {
            // Mood distribution
            String moodType = entry.getMoodType().toString();
            moodDistribution.put(moodType, moodDistribution.getOrDefault(moodType, 0) + 1);
            
            // Trigger analysis
            if (entry.getTriggers() != null) {
                for (MoodEntry.MoodTrigger trigger : entry.getTriggers()) {
                    String triggerName = trigger.toString();
                    triggerAnalysis.put(triggerName, triggerAnalysis.getOrDefault(triggerName, 0) + 1);
                }
            }
        }
        
        analytics.put("moodDistribution", moodDistribution);
        analytics.put("triggerAnalysis", triggerAnalysis);
        analytics.put("dateRange", Map.of("start", startDate, "end", endDate));
        
        return analytics;
    }
    
    public MoodEntry getMoodEntryById(Long id, User user) {
        return moodRepository.findById(id)
            .filter(entry -> entry.getUser().getId().equals(user.getId()))
            .orElseThrow(() -> new RuntimeException("Mood entry not found"));
    }
    
    public void deleteMoodEntry(Long id, User user) {
        MoodEntry entry = getMoodEntryById(id, user);
        moodRepository.delete(entry);
    }
}
