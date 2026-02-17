CREATE DATABASE IF NOT EXISTS mental_wellness;
USE mental_wellness;

-- ============================================================================
-- USERS TABLE - Core user information
-- ============================================================================
CREATE TABLE IF NOT EXISTS users1 (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    profile_picture VARCHAR(255),
    bio TEXT,
    phone_number VARCHAR(15),
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from users1;
-- ============================================================================
-- MOOD TRACKING TABLE - User mood entries
-- ============================================================================
CREATE TABLE IF NOT EXISTS moods (
    mood_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mood_type VARCHAR(50) NOT NULL,
    intensity INT CHECK (intensity >= 1 AND intensity <= 10),
    description TEXT, 
    trigge_r VARCHAR(255),
    location VARCHAR(100),
    activities VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_mood_type (mood_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from moods;
-- ============================================================================
-- EMOTION SESSIONS TABLE - Recording sessions metadata
-- ============================================================================
CREATE TABLE IF NOT EXISTS emotion_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    username VARCHAR(100) NOT NULL,
    session_name VARCHAR(100),
    session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_end TIMESTAMP NULL,
    session_status VARCHAR(20) DEFAULT 'active', -- active, completed, paused, cancelled
    duration_seconds INT,
    device_type VARCHAR(50), -- webcam, mobile, tablet, etc.
    location VARCHAR(100),
    environment_notes TEXT,
    lighting_condition VARCHAR(50), -- good, moderate, poor
    notes TEXT,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_session_start (session_start),
    INDEX idx_session_status (session_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from emotion_sessions;
-- ============================================================================
-- EMOTION DATA TABLE - ⭐ MAIN TABLE FOR REAL-TIME DETECTION
-- ============================================================================
CREATE TABLE IF NOT EXISTS emotion_data (
    emotion_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    username VARCHAR(100) NOT NULL,
    emotion_type VARCHAR(50) NOT NULL, -- angry, happy, sad, fear, disgust, neutral, surprise
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
    duration_seconds FLOAT,
    intensity_level VARCHAR(20), -- low, medium, high
    frame_count INT, -- number of frames for this emotion
    
    -- Additional tracking
    peak_confidence FLOAT,
    stability_score FLOAT, -- how stable was the emotion (0-100)
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Context
    notes TEXT,
    
    FOREIGN KEY (session_id) REFERENCES emotion_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_user_id (user_id),
    INDEX idx_session_id (session_id),
    INDEX idx_emotion_type (emotion_type),
    INDEX idx_detected_at (detected_at),
    INDEX idx_user_detected (user_id, detected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from emotion_data;
-- ============================================================================
-- EMOTION STATISTICS TABLE - Session aggregated data
-- ============================================================================
CREATE TABLE IF NOT EXISTS emotion_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    total_emotions INT,
    total_duration_seconds FLOAT,
    dominant_emotion VARCHAR(50),
    
    -- Emotion distribution JSON: {"angry": 5, "happy": 10, "sad": 2, ...}
    emotion_distribution JSON,
    
    -- Average metrics
    average_confidence FLOAT,
    average_intensity FLOAT,
    average_stability FLOAT,
    
    -- Session mood assessment
    session_mood VARCHAR(50), -- positive, neutral, negative
    wellness_score INT CHECK (wellness_score >= 0 AND wellness_score <= 100),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES emotion_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_session (session_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from emotion_stats;
-- ============================================================================
-- WELLNESS LOGS TABLE - User wellness tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS wellness_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT,
    
    -- Wellness assessment
    stress_level INT CHECK (stress_level >= 1 AND stress_level <= 10),
    anxiety_level INT CHECK (anxiety_level >= 1 AND anxiety_level <= 10),
    mood_description TEXT,
    wellness_score INT CHECK (wellness_score >= 0 AND wellness_score <= 100),
    energy_level INT CHECK (energy_level >= 1 AND energy_level <= 10),
    sleep_quality VARCHAR(50), -- excellent, good, fair, poor
    
    -- Recommendations
    recommendations TEXT,
    activities_suggested TEXT,
    
    -- Timestamp
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES emotion_sessions(session_id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from wellness_logs;
-- ============================================================================
-- DAILY SUMMARY TABLE - Daily aggregated wellness data
-- ============================================================================
CREATE TABLE IF NOT EXISTS daily_summary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    
    -- Session counts
    total_sessions INT,
    total_emotions_detected INT,
    total_detection_time INT, -- seconds
    
    -- Emotion metrics
    most_common_emotion VARCHAR(50),
    emotion_distribution JSON, -- {"angry": 15, "happy": 30, ...}
    
    -- Wellness metrics
    average_mood_score FLOAT,
    wellness_trend VARCHAR(50), -- improving, stable, declining
    average_stress_level FLOAT,
    average_anxiety_level FLOAT,
    average_energy_level FLOAT,
    
    -- Daily wellness score (0-100)
    daily_wellness_score INT,
    
    -- Summary
    summary_notes TEXT,
    
    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_user_date (user_id, date),
    INDEX idx_user_id (user_id),
    INDEX idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from daily_summary;
-- ============================================================================
-- RECOMMENDATIONS TABLE - Personalized recommendations
-- ============================================================================
CREATE TABLE IF NOT EXISTS recommendation (
    rec_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT,
    
    recommendation_text TEXT NOT NULL,
    category VARCHAR(50), -- exercise, meditation, social, sleep, nutrition, etc.
    priority VARCHAR(20), -- high, medium, low
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, dismissed, in_progress
    
    -- Tracking
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    dismissed_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES emotion_sessions(session_id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from recommendation;
-- ============================================================================
-- CHAT LOGS TABLE - Chatbot conversation history
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_logs (
    chat_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    username VARCHAR(100) NOT NULL,
    
    user_message TEXT NOT NULL,
    bot_response TEXT NOT NULL,
    message_type VARCHAR(50), -- support, recommendation, mood_tracking, etc.
    sentiment VARCHAR(50), -- positive, neutral, negative
    
    -- Context
    session_id INT,
    
    -- Timestamp
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES emotion_sessions(session_id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from chat_logs;
-- ============================================================================
-- EMOTION TRENDS TABLE - Weekly/Monthly trends
-- ============================================================================
CREATE TABLE IF NOT EXISTS emotion_trends (
    trend_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    period_type VARCHAR(20), -- weekly, monthly, quarterly
    period_start DATE,
    period_end DATE,
    
    -- Trend data
    dominant_emotion VARCHAR(50),
    emotion_volatility FLOAT, -- how much emotions changed
    overall_trend VARCHAR(50), -- improving, stable, declining
    
    -- Metrics
    average_wellness_score FLOAT,
    average_confidence FLOAT,
    detection_frequency INT, -- sessions per period
    
    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    INDEX idx_user_id (user_id),
    INDEX idx_period (period_start, period_end)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from emotion_trends;
-- ============================================================================
-- ALERTS TABLE - System alerts and notifications
-- ============================================================================
CREATE TABLE IF NOT EXISTS alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT,
    
    alert_type VARCHAR(50), -- critical_emotion, stress_alert, wellness_alert
    severity VARCHAR(20), -- critical, high, medium, low
    message TEXT,
    action_required BOOLEAN DEFAULT FALSE,
    
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    
    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES emotion_sessions(session_id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from alerts;
-- ============================================================================
-- AUDIT LOG TABLE - System audit trail
-- ============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100),
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
select * from audit_logs;
-- ============================================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: User's latest emotions
CREATE OR REPLACE VIEW user_latest_emotions AS
SELECT 
    u.user_id,
    u.username,
    ed.emotion_type,
    ed.confidence,
    ed.duration_seconds,
    ed.detected_at,
    es.session_name
FROM emotion_data ed
JOIN users1 u ON ed.user_id = u.user_id
JOIN emotion_sessions es ON ed.session_id = es.session_id
WHERE ed.detected_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY ed.detected_at DESC;

-- View: Daily emotion summary
CREATE OR REPLACE VIEW daily_emotion_summary AS
SELECT 
    DATE(ed.detected_at) as emotion_date,
    ed.user_id,
    u.username,
    COUNT(DISTINCT ed.session_id) as session_count,
    COUNT(ed.emotion_id) as total_emotions,
    ed.emotion_type as most_common_emotion,
    AVG(ed.confidence) as avg_confidence,
    MAX(ed.detected_at) as last_detection
FROM emotion_data ed
JOIN users1 u ON ed.user_id = u.user_id
GROUP BY DATE(ed.detected_at), ed.user_id, ed.emotion_type
ORDER BY emotion_date DESC, ed.user_id;

-- View: Weekly wellness summary
CREATE OR REPLACE VIEW weekly_wellness_summary AS
SELECT 
    u.user_id,
    u.username,
    WEEK(NOW()) as week_number,
    COUNT(DISTINCT es.session_id) as total_sessions,
    AVG(es_stats.wellness_score) as avg_wellness_score,
    COUNT(DISTINCT ed.emotion_id) as total_emotions_detected
FROM users1 u
LEFT JOIN emotion_sessions es ON u.user_id = es.user_id 
    AND WEEK(es.session_start) = WEEK(NOW())
LEFT JOIN emotion_data ed ON es.session_id = ed.session_id
LEFT JOIN emotion_stats es_stats ON es.session_id = es_stats.session_id
GROUP BY u.user_id, u.username;

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Performance indexes for emotion_data queries
CREATE INDEX idx_emotion_data_user_date ON emotion_data(user_id, detected_at);
CREATE INDEX idx_emotion_data_type_date ON emotion_data(emotion_type, detected_at);
CREATE INDEX idx_emotion_data_session_type ON emotion_data(session_id, emotion_type);

-- Performance indexes for sessions
CREATE INDEX idx_sessions_user_date ON emotion_sessions(user_id, session_start);
CREATE INDEX idx_sessions_status_date ON emotion_sessions(session_status, session_start);

-- Performance indexes for daily summary
CREATE INDEX idx_daily_summary_user_date ON daily_summary(user_id, date);

-- ============================================================================
-- CREATE STORED PROCEDURES
-- ============================================================================

-- Procedure: Calculate daily summary
DELIMITER $$

CREATE PROCEDURE CalculateDailySummary(IN p_user_id INT, IN p_date DATE)
BEGIN
    DECLARE v_total_sessions INT;
    DECLARE v_total_emotions INT;
    DECLARE v_dominant_emotion VARCHAR(50);
    DECLARE v_avg_mood FLOAT;
    DECLARE v_wellness_score INT;
    
    -- Count sessions
    SELECT COUNT(DISTINCT session_id) INTO v_total_sessions
    FROM emotion_sessions
    WHERE user_id = p_user_id AND DATE(session_start) = p_date;
    
    -- Count emotions
    SELECT COUNT(*) INTO v_total_emotions
    FROM emotion_data
    WHERE user_id = p_user_id AND DATE(detected_at) = p_date;
    
    -- Get dominant emotion
    SELECT emotion_type INTO v_dominant_emotion
    FROM emotion_data
    WHERE user_id = p_user_id AND DATE(detected_at) = p_date
    GROUP BY emotion_type
    ORDER BY COUNT(*) DESC
    LIMIT 1;
    
    -- Calculate wellness score (example formula)
    SET v_wellness_score = LEAST(100, GREATEST(0, 
        50 + (v_total_sessions * 10) - (IF(v_dominant_emotion = 'angry', 20, 0))
    ));
    
    -- Insert or update daily summary
    INSERT INTO daily_summary 
    (user_id, date, total_sessions, total_emotions_detected, 
     most_common_emotion, daily_wellness_score)
    VALUES (p_user_id, p_date, v_total_sessions, v_total_emotions, 
            v_dominant_emotion, v_wellness_score)
    ON DUPLICATE KEY UPDATE
        total_sessions = v_total_sessions,
        total_emotions_detected = v_total_emotions,
        most_common_emotion = v_dominant_emotion,
        daily_wellness_score = v_wellness_score,
        updated_at = NOW();
        
END$$

DELIMITER ;

-- ============================================================================
-- INSERT SAMPLE DATA (Optional)
-- ============================================================================

-- Sample user
INSERT INTO users1 (username, email, password_hash, full_name, age, gender)
VALUES ('demo_user', 'demo@mentalwellness.com', 'hashed_password_123', 'Demo User', 25, 'M');

-- Sample session
INSERT INTO emotion_sessions (user_id, username, session_name, device_type, location)
VALUES (1, 'demo_user', 'Morning Detection Session', 'webcam', 'Office');

-- Sample emotions
INSERT INTO emotion_data 
(session_id, user_id, username, emotion_type, confidence, duration_seconds, intensity_level)
VALUES 
(1, 1, 'demo_user', 'happy', 0.95, 5.2, 'high'),
(1, 1, 'demo_user', 'neutral', 0.87, 3.1, 'medium'),
(1, 1, 'demo_user', 'happy', 0.92, 4.8, 'high');

-- ============================================================================
-- PRINT SCHEMA SUMMARY
-- ============================================================================
-- Run this to verify schema:
SELECT TABLE_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES 
 WHERE TABLE_SCHEMA = 'mental_wellness';