package com.wellness.wellness_assistant.repository;

import com.wellness.wellness_assistant.model.ProfessionalHelp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProfessionalHelpRepository extends JpaRepository<ProfessionalHelp, Long> {
    
    List<ProfessionalHelp> findByTypeAndIsAvailableTrue(ProfessionalHelp.ProfessionalType type);
    
    List<ProfessionalHelp> findByIsAvailableTrueOrderByRatingDesc();
    
    List<ProfessionalHelp> findByOnlineConsultationTrueAndIsAvailableTrue();
    
    @Query("SELECT p FROM ProfessionalHelp p WHERE p.isAvailable = true AND " +
           "(p.professionalName LIKE %:keyword% OR p.specialization LIKE %:keyword%)")
    List<ProfessionalHelp> searchByKeyword(String keyword);
    
    List<ProfessionalHelp> findByLocationContainingIgnoreCaseAndIsAvailableTrue(String location);
}