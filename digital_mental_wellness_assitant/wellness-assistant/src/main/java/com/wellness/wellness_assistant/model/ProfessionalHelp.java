package com.wellness.wellness_assistant.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "professional_help")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfessionalHelp {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "professional_name", nullable = false)
    private String professionalName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProfessionalType type;
    
    @Column(nullable = false)
    private String specialization;
    
    @Column(name = "contact_email")
    private String contactEmail;
    
    @Column(name = "contact_phone")
    private String contactPhone;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "years_experience")
    private Integer yearsExperience;
    
    @Column(name = "license_number")
    private String licenseNumber;
    
    @Column(name = "consultation_fee")
    private Double consultationFee;
    
    @Column(name = "is_available")
    private Boolean isAvailable = true;
    
    @Column(name = "location")
    private String location;
    
    @Column(name = "online_consultation")
    private Boolean onlineConsultation = false;
    
    @Column(name = "rating")
    private Double rating; // Average rating
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum ProfessionalType {
        PSYCHOLOGIST, PSYCHIATRIST, COUNSELOR, THERAPIST, SOCIAL_WORKER, 
        LIFE_COACH, PEER_SUPPORT_SPECIALIST
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}