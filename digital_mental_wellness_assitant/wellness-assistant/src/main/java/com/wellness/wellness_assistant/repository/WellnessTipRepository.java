package com.wellness.wellness_assistant.repository;

import com.wellness.wellness_assistant.model.WellnessTip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WellnessTipRepository extends JpaRepository<WellnessTip, Long> {
    
    List<WellnessTip> findByCategory(WellnessTip.Category category);
    
    List<WellnessTip> findByIsFeaturedTrueOrderByCreatedAtDesc();
    
    @Query("SELECT w FROM WellnessTip w ORDER BY w.createdAt DESC")
    List<WellnessTip> findAllOrderByCreatedAtDesc();
    
    @Query("SELECT w FROM WellnessTip w WHERE w.title LIKE %:keyword% OR w.content LIKE %:keyword%")
    List<WellnessTip> searchByKeyword(String keyword);
}