package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.model.WellnessTip;
import com.wellness.wellness_assistant.service.WellnessTipService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/wellness-tips")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class WellnessTipController {
    
    private final WellnessTipService wellnessTipService;
    
    @GetMapping
    public ResponseEntity<List<WellnessTip>> getAllTips() {
        try {
            List<WellnessTip> tips = wellnessTipService.getAllTips();
            return ResponseEntity.ok(tips);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/featured")
    public ResponseEntity<List<WellnessTip>> getFeaturedTips() {
        try {
            List<WellnessTip> tips = wellnessTipService.getFeaturedTips();
            return ResponseEntity.ok(tips);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/category/{category}")
    public ResponseEntity<List<WellnessTip>> getTipsByCategory(@PathVariable WellnessTip.Category category) {
        try {
            List<WellnessTip> tips = wellnessTipService.getTipsByCategory(category);
            return ResponseEntity.ok(tips);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<WellnessTip>> searchTips(@RequestParam String keyword) {
        try {
            List<WellnessTip> tips = wellnessTipService.searchTips(keyword);
            return ResponseEntity.ok(tips);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<WellnessTip> getTipById(@PathVariable Long id) {
        try {
            WellnessTip tip = wellnessTipService.getTipById(id);
            return ResponseEntity.ok(tip);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping
    public ResponseEntity<WellnessTip> createTip(@RequestBody WellnessTip tip) {
        try {
            WellnessTip createdTip = wellnessTipService.createTip(tip);
            return ResponseEntity.ok(createdTip);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<WellnessTip> updateTip(@PathVariable Long id, @RequestBody WellnessTip tip) {
        try {
            WellnessTip updatedTip = wellnessTipService.updateTip(id, tip);
            return ResponseEntity.ok(updatedTip);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTip(@PathVariable Long id) {
        try {
            wellnessTipService.deleteTip(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}