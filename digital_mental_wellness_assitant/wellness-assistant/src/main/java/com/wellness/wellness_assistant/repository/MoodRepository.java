package com.wellness.wellness_assistant.repository;

import com.wellness.wellness_assistant.model.MoodEntry;
import com.wellness.wellness_assistant.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MoodRepository extends JpaRepository<MoodEntry, Long> {
    
    List<MoodEntry> findByUserOrderByCreatedAtDesc(User user);
    
    List<MoodEntry> findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(
        User user, LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT m FROM MoodEntry m WHERE m.user = :user AND m.createdAt >= :startDate")
    List<MoodEntry> findRecentMoodEntries(@Param("user") User user, @Param("startDate") LocalDateTime startDate);
    
    @Query("SELECT AVG(m.moodIntensity) FROM MoodEntry m WHERE m.user = :user AND m.createdAt >= :startDate")
    Double getAverageMoodIntensity(@Param("user") User user, @Param("startDate") LocalDateTime startDate);
    
    long countByUserAndCreatedAtBetween(User user, LocalDateTime startDate, LocalDateTime endDate);
}
