package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.model.WellnessTip;
import com.wellness.wellness_assistant.repository.WellnessTipRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WellnessTipService {
    
    private final WellnessTipRepository wellnessTipRepository;
    
    public List<WellnessTip> getAllTips() {
        return wellnessTipRepository.findAllOrderByCreatedAtDesc();
    }
    
    public List<WellnessTip> getTipsByCategory(WellnessTip.Category category) {
        return wellnessTipRepository.findByCategory(category);
    }
    
    public List<WellnessTip> getFeaturedTips() {
        return wellnessTipRepository.findByIsFeaturedTrueOrderByCreatedAtDesc();
    }
    
    public List<WellnessTip> searchTips(String keyword) {
        return wellnessTipRepository.searchByKeyword(keyword);
    }
    
    public WellnessTip getTipById(Long id) {
        return wellnessTipRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Wellness tip not found"));
    }
    
    public WellnessTip createTip(WellnessTip tip) {
        return wellnessTipRepository.save(tip);
    }
    
    public WellnessTip updateTip(Long id, WellnessTip updatedTip) {
        WellnessTip existingTip = getTipById(id);
        existingTip.setTitle(updatedTip.getTitle());
        existingTip.setContent(updatedTip.getContent());
        existingTip.setCategory(updatedTip.getCategory());
        existingTip.setImageUrl(updatedTip.getImageUrl());
        existingTip.setReadTimeMinutes(updatedTip.getReadTimeMinutes());
        existingTip.setIsFeatured(updatedTip.getIsFeatured());
        
        return wellnessTipRepository.save(existingTip);
    }
    
    public void deleteTip(Long id) {
        WellnessTip tip = getTipById(id);
        wellnessTipRepository.delete(tip);
    }
}