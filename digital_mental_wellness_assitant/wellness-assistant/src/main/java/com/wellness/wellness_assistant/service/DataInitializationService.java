package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.model.ProfessionalHelp;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.model.WellnessTip;
import com.wellness.wellness_assistant.repository.ProfessionalHelpRepository;
import com.wellness.wellness_assistant.repository.UserRepository;
import com.wellness.wellness_assistant.repository.WellnessTipRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class DataInitializationService implements CommandLineRunner {
    
    private final WellnessTipRepository wellnessTipRepository;
    private final ProfessionalHelpRepository professionalHelpRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Value("${app.data.seed:true}")
    private boolean seedData;
    
    @Override
    public void run(String... args) throws Exception {
        if (!seedData) {
            log.info("Data seeding is disabled");
            return;
        }
        
        log.info("Starting data initialization for development environment...");
        
        try {
            initializeAdminUser();
            initializeWellnessTips();
            initializeProfessionals();
            log.info("Data initialization completed successfully");
        } catch (Exception e) {
            log.error("Error during data initialization", e);
        }
    }
    
    private void initializeAdminUser() {
        if (userRepository.findByEmail("admin@wellness.com").isEmpty()) {
            User adminUser = new User();
            adminUser.setEmail("admin@wellness.com");
            adminUser.setPassword(passwordEncoder.encode("admin123"));
            adminUser.setFirstName("Admin");
            adminUser.setLastName("User");
            adminUser.setGender(User.Gender.PREFER_NOT_TO_SAY);
            adminUser.setIsActive(true);
            
            userRepository.save(adminUser);
            log.info("Admin user created: admin@wellness.com / admin123");
        }
        
        if (userRepository.findByEmail("demo@wellness.com").isEmpty()) {
            User demoUser = new User();
            demoUser.setEmail("demo@wellness.com");
            demoUser.setPassword(passwordEncoder.encode("demo123"));
            demoUser.setFirstName("Demo");
            demoUser.setLastName("User");
            demoUser.setDateOfBirth("1990-01-01");
            demoUser.setPhoneNumber("+1-555-0123");
            demoUser.setGender(User.Gender.OTHER);
            demoUser.setEmergencyContact("Emergency Contact");
            demoUser.setEmergencyPhone("+1-555-0124");
            demoUser.setIsActive(true);
            
            userRepository.save(demoUser);
            log.info("Demo user created: demo@wellness.com / demo123");
        }
    }
    
    private void initializeWellnessTips() {
        if (wellnessTipRepository.count() == 0) {
            log.info("Initializing wellness tips...");
            
            // Stress Management Tips
            WellnessTip tip1 = new WellnessTip();
            tip1.setTitle("5-Minute Breathing Exercise for Stress Relief");
            tip1.setContent("Try the 4-7-8 breathing technique: Inhale for 4 counts, hold for 7 counts, exhale for 8 counts. Repeat 4 times to instantly reduce stress and anxiety.");
            tip1.setCategory(WellnessTip.Category.STRESS_MANAGEMENT);
            tip1.setReadTimeMinutes(2);
            tip1.setIsFeatured(true);
            wellnessTipRepository.save(tip1);
            
            WellnessTip tip2 = new WellnessTip();
            tip2.setTitle("Mindful Morning Routine");
            tip2.setContent("Start your day with intention: 1) Gentle stretching, 2) 5 minutes of meditation, 3) Write down 3 things you're grateful for, 4) Set one positive intention for the day.");
            tip2.setCategory(WellnessTip.Category.MINDFULNESS);
            tip2.setReadTimeMinutes(3);
            tip2.setIsFeatured(true);
            wellnessTipRepository.save(tip2);
            
            WellnessTip tip3 = new WellnessTip();
            tip3.setTitle("Sleep Hygiene for Better Mental Health");
            tip3.setContent("Good sleep is crucial for mental wellness: Keep a consistent sleep schedule, avoid screens 1 hour before bed, create a cool, dark environment, and try relaxation techniques like progressive muscle relaxation.");
            tip3.setCategory(WellnessTip.Category.SLEEP_HYGIENE);
            tip3.setReadTimeMinutes(4);
            tip3.setIsFeatured(false);
            wellnessTipRepository.save(tip3);
            
            WellnessTip tip4 = new WellnessTip();
            tip4.setTitle("Building Healthy Relationships");
            tip4.setContent("Strong relationships support mental health: Practice active listening, express appreciation regularly, set healthy boundaries, communicate openly about feelings, and make time for meaningful connections.");
            tip4.setCategory(WellnessTip.Category.RELATIONSHIPS);
            tip4.setReadTimeMinutes(5);
            tip4.setIsFeatured(false);
            wellnessTipRepository.save(tip4);
            
            WellnessTip tip5 = new WellnessTip();
            tip5.setTitle("Managing Anxiety in Daily Life");
            tip5.setContent("Practical anxiety management techniques: Ground yourself using the 5-4-3-2-1 method (5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste), practice deep breathing, challenge negative thoughts, and maintain a regular exercise routine.");
            tip5.setCategory(WellnessTip.Category.ANXIETY_RELIEF);
            tip5.setReadTimeMinutes(4);
            tip5.setIsFeatured(true);
            wellnessTipRepository.save(tip5);
            
            log.info("Created {} wellness tips", wellnessTipRepository.count());
        }
    }
    
    private void initializeProfessionals() {
        if (professionalHelpRepository.count() == 0) {
            log.info("Initializing professional help data...");
            
            ProfessionalHelp prof1 = new ProfessionalHelp();
            prof1.setProfessionalName("Dr. Sarah Johnson");
            prof1.setType(ProfessionalHelp.ProfessionalType.PSYCHOLOGIST);
            prof1.setSpecialization("Anxiety and Depression Treatment");
            prof1.setContactEmail("sarah.johnson@mentalhealth.com");
            prof1.setContactPhone("+1 (555) 123-4567");
            prof1.setDescription("Dr. Johnson specializes in cognitive behavioral therapy (CBT) and has over 10 years of experience helping clients overcome anxiety and depression.");
            prof1.setYearsExperience(10);
            prof1.setLicenseNumber("PSY-12345");
            prof1.setConsultationFee(150.0);
            prof1.setLocation("New York, NY");
            prof1.setOnlineConsultation(true);
            prof1.setRating(4.8);
            professionalHelpRepository.save(prof1);
            
            ProfessionalHelp prof2 = new ProfessionalHelp();
            prof2.setProfessionalName("Dr. Michael Chen");
            prof2.setType(ProfessionalHelp.ProfessionalType.PSYCHIATRIST);
            prof2.setSpecialization("Mood Disorders and Medication Management");
            prof2.setContactEmail("michael.chen@psychiatry.com");
            prof2.setContactPhone("+1 (555) 234-5678");
            prof2.setDescription("Dr. Chen is a board-certified psychiatrist with expertise in treating mood disorders, ADHD, and anxiety disorders through both therapy and medication management.");
            prof2.setYearsExperience(15);
            prof2.setLicenseNumber("MD-67890");
            prof2.setConsultationFee(200.0);
            prof2.setLocation("Los Angeles, CA");
            prof2.setOnlineConsultation(true);
            prof2.setRating(4.9);
            professionalHelpRepository.save(prof2);
            
            ProfessionalHelp prof3 = new ProfessionalHelp();
            prof3.setProfessionalName("Lisa Thompson, LCSW");
            prof3.setType(ProfessionalHelp.ProfessionalType.COUNSELOR);
            prof3.setSpecialization("Trauma and PTSD Treatment");
            prof3.setContactEmail("lisa.thompson@counseling.com");
            prof3.setContactPhone("+1 (555) 345-6789");
            prof3.setDescription("Lisa is a licensed clinical social worker specializing in trauma-informed care, EMDR therapy, and supporting survivors of various forms of trauma.");
            prof3.setYearsExperience(8);
            prof3.setLicenseNumber("LCSW-11111");
            prof3.setConsultationFee(120.0);
            prof3.setLocation("Chicago, IL");
            prof3.setOnlineConsultation(false);
            prof3.setRating(4.7);
            professionalHelpRepository.save(prof3);
            
            ProfessionalHelp prof4 = new ProfessionalHelp();
            prof4.setProfessionalName("Dr. Emily Rodriguez");
            prof4.setType(ProfessionalHelp.ProfessionalType.THERAPIST);
            prof4.setSpecialization("Family and Couples Therapy");
            prof4.setContactEmail("emily.rodriguez@therapy.com");
            prof4.setContactPhone("+1 (555) 456-7890");
            prof4.setDescription("Dr. Rodriguez specializes in family systems therapy and couples counseling, helping families and couples build stronger, healthier relationships.");
            prof4.setYearsExperience(12);
            prof4.setLicenseNumber("MFT-22222");
            prof4.setConsultationFee(140.0);
            prof4.setLocation("Austin, TX");
            prof4.setOnlineConsultation(true);
            prof4.setRating(4.6);
            professionalHelpRepository.save(prof4);
            
            log.info("Created {} professional help entries", professionalHelpRepository.count());
        }
    }
}