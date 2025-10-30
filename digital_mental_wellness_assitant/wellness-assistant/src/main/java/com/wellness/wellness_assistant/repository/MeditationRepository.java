package com.wellness.wellness_assistant.repository;

import com.wellness.wellness_assistant.model.MeditationSession;
import com.wellness.wellness_assistant.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MeditationRepository extends JpaRepository<MeditationSession, Long> {
    
    List<MeditationSession> findByUserOrderByCompletedAtDesc(User user);
    
    List<MeditationSession> findByUserAndCompletedAtBetweenOrderByCompletedAtDesc(
        User user, LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT SUM(m.durationMinutes) FROM MeditationSession m WHERE m.user = :user AND m.completedAt >= :startDate")
    Long getTotalMeditationTime(@Param("user") User user, @Param("startDate") LocalDateTime startDate);
    
    @Query("SELECT AVG(m.rating) FROM MeditationSession m WHERE m.user = :user AND m.rating IS NOT NULL")
    Double getAverageRating(@Param("user") User user);
    
    long countByUserAndCompletedAtBetween(User user, LocalDateTime startDate, LocalDateTime endDate);
}