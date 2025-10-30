package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.model.ProfessionalHelp;
import com.wellness.wellness_assistant.repository.ProfessionalHelpRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProfessionalHelpService {
    
    private final ProfessionalHelpRepository professionalHelpRepository;
    
    public List<ProfessionalHelp> getAllProfessionals() {
        return professionalHelpRepository.findByIsAvailableTrueOrderByRatingDesc();
    }
    
    public List<ProfessionalHelp> getProfessionalsByType(ProfessionalHelp.ProfessionalType type) {
        return professionalHelpRepository.findByTypeAndIsAvailableTrue(type);
    }
    
    public List<ProfessionalHelp> getOnlineProfessionals() {
        return professionalHelpRepository.findByOnlineConsultationTrueAndIsAvailableTrue();
    }
    
    public List<ProfessionalHelp> searchProfessionals(String keyword) {
        return professionalHelpRepository.searchByKeyword(keyword);
    }
    
    public List<ProfessionalHelp> getProfessionalsByLocation(String location) {
        return professionalHelpRepository.findByLocationContainingIgnoreCaseAndIsAvailableTrue(location);
    }
    
    public ProfessionalHelp getProfessionalById(Long id) {
        return professionalHelpRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Professional not found"));
    }
    
    public ProfessionalHelp createProfessional(ProfessionalHelp professional) {
        return professionalHelpRepository.save(professional);
    }
    
    public ProfessionalHelp updateProfessional(Long id, ProfessionalHelp updatedProfessional) {
        ProfessionalHelp existingProfessional = getProfessionalById(id);
        existingProfessional.setProfessionalName(updatedProfessional.getProfessionalName());
        existingProfessional.setType(updatedProfessional.getType());
        existingProfessional.setSpecialization(updatedProfessional.getSpecialization());
        existingProfessional.setContactEmail(updatedProfessional.getContactEmail());
        existingProfessional.setContactPhone(updatedProfessional.getContactPhone());
        existingProfessional.setDescription(updatedProfessional.getDescription());
        existingProfessional.setYearsExperience(updatedProfessional.getYearsExperience());
        existingProfessional.setConsultationFee(updatedProfessional.getConsultationFee());
        existingProfessional.setLocation(updatedProfessional.getLocation());
        existingProfessional.setOnlineConsultation(updatedProfessional.getOnlineConsultation());
        existingProfessional.setIsAvailable(updatedProfessional.getIsAvailable());
        
        return professionalHelpRepository.save(existingProfessional);
    }
    
    public void deleteProfessional(Long id) {
        ProfessionalHelp professional = getProfessionalById(id);
        professionalHelpRepository.delete(professional);
    }
}