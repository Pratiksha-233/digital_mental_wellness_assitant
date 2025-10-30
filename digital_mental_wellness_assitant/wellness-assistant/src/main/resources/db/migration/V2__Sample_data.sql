-- Insert sample wellness tips
-- Version: 1.1.0
-- Date: 2025-10-30

INSERT INTO wellness_tips (title, content, category, read_time_minutes, is_featured) VALUES
('5-Minute Breathing Exercise for Stress Relief', 
 'Try the 4-7-8 breathing technique: Inhale for 4 counts, hold for 7 counts, exhale for 8 counts. Repeat 4 times to instantly reduce stress and anxiety. This technique activates your parasympathetic nervous system, promoting relaxation and reducing cortisol levels.',
 'STRESS_MANAGEMENT', 2, TRUE),

('Mindful Morning Routine for Mental Clarity',
 'Start your day with intention: 1) Gentle stretching for 5 minutes, 2) 5 minutes of meditation or deep breathing, 3) Write down 3 things you''re grateful for, 4) Set one positive intention for the day. This routine helps establish a positive mindset and reduces morning anxiety.',
 'MINDFULNESS', 3, TRUE),

('Sleep Hygiene for Better Mental Health',
 'Good sleep is crucial for mental wellness: Keep a consistent sleep schedule (even on weekends), avoid screens 1 hour before bed, create a cool, dark environment (60-67°F), and try relaxation techniques like progressive muscle relaxation. Quality sleep improves mood regulation and cognitive function.',
 'SLEEP_HYGIENE', 4, FALSE),

('Building Healthy Relationships',
 'Strong relationships support mental health: Practice active listening without planning your response, express appreciation regularly (aim for 5:1 positive to negative interactions), set healthy boundaries by saying no when needed, communicate openly about feelings using "I" statements, and make time for meaningful connections.',
 'RELATIONSHIPS', 5, FALSE),

('Managing Anxiety in Daily Life',
 'Practical anxiety management techniques: Ground yourself using the 5-4-3-2-1 method (5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste), practice deep breathing exercises, challenge negative thoughts with evidence-based thinking, maintain a regular exercise routine, and limit caffeine intake.',
 'ANXIETY_RELIEF', 4, TRUE),

('Nutrition for Mental Wellness',
 'What you eat affects how you feel: Include omega-3 rich foods (salmon, walnuts, flaxseeds), maintain stable blood sugar with regular meals, limit processed foods and sugar, stay hydrated (8-10 glasses of water daily), and consider probiotic foods for gut-brain health. A balanced diet supports neurotransmitter production.',
 'NUTRITION', 6, FALSE),

('Exercise for Mental Health Benefits',
 'Physical activity is a natural mood booster: Aim for 30 minutes of moderate exercise 5 days a week, try activities you enjoy (dancing, hiking, swimming), use the 10-minute rule (commit to just 10 minutes when motivation is low), exercise outdoors when possible for additional vitamin D benefits.',
 'EXERCISE', 4, TRUE),

('Work-Life Balance Strategies',
 'Prevent burnout with these strategies: Set clear boundaries between work and personal time, take regular breaks (5 minutes every hour), practice the "two-minute rule" for small tasks, delegate when possible, and establish a wind-down routine after work. Remember: productivity isn''t about being busy.',
 'WORK_LIFE_BALANCE', 5, FALSE),

('Self-Care Beyond Bubble Baths',
 'True self-care includes: Setting boundaries with toxic people, saying no to overcommitment, regular health check-ups, financial planning for reduced stress, learning new skills for confidence, spending time in nature, and practicing self-compassion. Self-care is about sustaining yourself long-term.',
 'SELF_CARE', 6, FALSE),

('Coping with Depression: Small Steps',
 'When depression feels overwhelming: Start with micro-goals (brush teeth, make bed), maintain a routine even if it''s simple, get sunlight exposure daily (10-15 minutes), reach out to one person, practice the "opposite action" technique when motivation is low, and remember that small progress is still progress.',
 'DEPRESSION_SUPPORT', 5, TRUE);

-- Insert sample professional help data
INSERT INTO professional_help (professional_name, type, specialization, contact_email, contact_phone, description, years_experience, license_number, consultation_fee, location, online_consultation, rating) VALUES
('Dr. Sarah Johnson', 'PSYCHOLOGIST', 'Anxiety and Depression Treatment', 'sarah.johnson@mentalhealth.com', '+1 (555) 123-4567', 
 'Dr. Johnson specializes in cognitive behavioral therapy (CBT) and has over 10 years of experience helping clients overcome anxiety and depression. She uses evidence-based treatments and creates a warm, supportive environment for healing.',
 10, 'PSY-12345', 150.00, 'New York, NY', TRUE, 4.8),

('Dr. Michael Chen', 'PSYCHIATRIST', 'Mood Disorders and Medication Management', 'michael.chen@psychiatry.com', '+1 (555) 234-5678',
 'Dr. Chen is a board-certified psychiatrist with expertise in treating mood disorders, ADHD, and anxiety disorders through both therapy and medication management. He takes a holistic approach to mental health treatment.',
 15, 'MD-67890', 200.00, 'Los Angeles, CA', TRUE, 4.9),

('Lisa Thompson, LCSW', 'COUNSELOR', 'Trauma and PTSD Treatment', 'lisa.thompson@counseling.com', '+1 (555) 345-6789',
 'Lisa is a licensed clinical social worker specializing in trauma-informed care, EMDR therapy, and supporting survivors of various forms of trauma. She provides a safe space for processing difficult experiences.',
 8, 'LCSW-11111', 120.00, 'Chicago, IL', FALSE, 4.7),

('Dr. Emily Rodriguez', 'THERAPIST', 'Family and Couples Therapy', 'emily.rodriguez@therapy.com', '+1 (555) 456-7890',
 'Dr. Rodriguez specializes in family systems therapy and couples counseling, helping families and couples build stronger, healthier relationships. She uses evidence-based approaches like Gottman Method and EFT.',
 12, 'MFT-22222', 140.00, 'Austin, TX', TRUE, 4.6),

('James Wilson, MA', 'LIFE_COACH', 'Career and Life Transitions', 'james.wilson@lifecoaching.com', '+1 (555) 567-8901',
 'James helps individuals navigate major life transitions, career changes, and personal growth goals. He combines coaching techniques with mindfulness practices to help clients create meaningful, fulfilling lives.',
 7, 'LC-33333', 80.00, 'Seattle, WA', TRUE, 4.5),

('Dr. Amanda Foster', 'PSYCHOLOGIST', 'Child and Adolescent Psychology', 'amanda.foster@childpsych.com', '+1 (555) 678-9012',
 'Dr. Foster specializes in working with children, teenagers, and their families. She addresses issues like ADHD, anxiety, depression, and behavioral challenges using play therapy and family-centered approaches.',
 14, 'PSY-44444', 160.00, 'Denver, CO', FALSE, 4.9);

-- Insert sample community posts (these would typically be created by users)
INSERT INTO community_posts (user_id, title, content, category, is_anonymous, likes_count, comments_count, is_pinned) VALUES
(1, 'Daily Check-in: How are you feeling today?', 
 'Let''s start our day by sharing how we''re feeling. Remember, it''s okay to not be okay. This is a safe space to express yourself.', 
 'DAILY_CHECK_IN', FALSE, 15, 8, TRUE),

(1, 'Gratitude Practice: Three Good Things', 
 'Research shows that writing down three good things that happened each day can significantly improve mood and overall well-being. What are your three good things from today?',
 'GENERAL_SUPPORT', FALSE, 23, 12, FALSE),

(1, 'Anxiety Management Techniques That Actually Work',
 'I''ve been dealing with anxiety for years and wanted to share some techniques that have really helped me: box breathing, progressive muscle relaxation, and the 5-4-3-2-1 grounding technique. What works for you?',
 'ANXIETY_DEPRESSION', TRUE, 45, 28, FALSE),

(1, 'Success Story: 6 Months of Therapy',
 'Six months ago, I started therapy feeling hopeless and overwhelmed. Today, I can say that seeking help was the best decision I ever made. If you''re considering therapy, this is your sign to take that first step.',
 'SUCCESS_STORIES', FALSE, 67, 34, TRUE);