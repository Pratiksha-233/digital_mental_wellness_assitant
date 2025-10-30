package com.wellness.wellness_assistant.repository;

import com.wellness.wellness_assistant.model.CommunityPost;
import com.wellness.wellness_assistant.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommunityPostRepository extends JpaRepository<CommunityPost, Long> {
    
    List<CommunityPost> findByIsApprovedTrueOrderByCreatedAtDesc();
    
    List<CommunityPost> findByCategoryAndIsApprovedTrueOrderByCreatedAtDesc(CommunityPost.Category category);
    
    List<CommunityPost> findByAuthorAndIsApprovedTrueOrderByCreatedAtDesc(User author);
    
    List<CommunityPost> findByIsPinnedTrueAndIsApprovedTrueOrderByCreatedAtDesc();
    
    @Query("SELECT p FROM CommunityPost p WHERE p.isApproved = true AND " +
           "(p.title LIKE %:keyword% OR p.content LIKE %:keyword%) ORDER BY p.createdAt DESC")
    List<CommunityPost> searchByKeyword(String keyword);
}