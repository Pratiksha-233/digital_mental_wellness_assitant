package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.model.ProfessionalHelp;
import com.wellness.wellness_assistant.service.ProfessionalHelpService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/professionals")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProfessionalHelpController {
    
    private final ProfessionalHelpService professionalHelpService;
    
    @GetMapping
    public ResponseEntity<List<ProfessionalHelp>> getAllProfessionals() {
        try {
            List<ProfessionalHelp> professionals = professionalHelpService.getAllProfessionals();
            return ResponseEntity.ok(professionals);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<List<ProfessionalHelp>> getProfessionalsByType(
            @PathVariable ProfessionalHelp.ProfessionalType type) {
        try {
            List<ProfessionalHelp> professionals = professionalHelpService.getProfessionalsByType(type);
            return ResponseEntity.ok(professionals);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/online")
    public ResponseEntity<List<ProfessionalHelp>> getOnlineProfessionals() {
        try {
            List<ProfessionalHelp> professionals = professionalHelpService.getOnlineProfessionals();
            return ResponseEntity.ok(professionals);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<ProfessionalHelp>> searchProfessionals(@RequestParam String keyword) {
        try {
            List<ProfessionalHelp> professionals = professionalHelpService.searchProfessionals(keyword);
            return ResponseEntity.ok(professionals);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/location")
    public ResponseEntity<List<ProfessionalHelp>> getProfessionalsByLocation(@RequestParam String location) {
        try {
            List<ProfessionalHelp> professionals = professionalHelpService.getProfessionalsByLocation(location);
            return ResponseEntity.ok(professionals);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ProfessionalHelp> getProfessionalById(@PathVariable Long id) {
        try {
            ProfessionalHelp professional = professionalHelpService.getProfessionalById(id);
            return ResponseEntity.ok(professional);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping
    public ResponseEntity<ProfessionalHelp> createProfessional(@RequestBody ProfessionalHelp professional) {
        try {
            ProfessionalHelp createdProfessional = professionalHelpService.createProfessional(professional);
            return ResponseEntity.ok(createdProfessional);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ProfessionalHelp> updateProfessional(
            @PathVariable Long id, 
            @RequestBody ProfessionalHelp professional) {
        try {
            ProfessionalHelp updatedProfessional = professionalHelpService.updateProfessional(id, professional);
            return ResponseEntity.ok(updatedProfessional);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProfessional(@PathVariable Long id) {
        try {
            professionalHelpService.deleteProfessional(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}