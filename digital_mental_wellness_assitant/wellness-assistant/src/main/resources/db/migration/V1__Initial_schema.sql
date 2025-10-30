-- Initial schema creation for Digital Mental Wellness Assistant
-- Version: 1.0.0
-- Date: 2025-10-30

-- Create users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth VARCHAR(20),
    phone_number VARCHAR(20),
    gender VARCHAR(50),
    emergency_contact VARCHAR(255),
    emergency_phone VARCHAR(20),
    profile_picture_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create mood_entries table
CREATE TABLE mood_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    mood_type VARCHAR(50) NOT NULL,
    mood_intensity INT CHECK (mood_intensity >= 1 AND mood_intensity <= 10),
    mood_notes TEXT,
    sleep_hours DECIMAL(3,1) CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
    exercise_minutes INT CHECK (exercise_minutes >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create mood_triggers table for many-to-many relationship
CREATE TABLE mood_triggers (
    mood_entry_id BIGINT NOT NULL,
    trigger_value VARCHAR(50) NOT NULL,
    FOREIGN KEY (mood_entry_id) REFERENCES mood_entries(id) ON DELETE CASCADE
);

-- Create mood_activities table for many-to-many relationship
CREATE TABLE mood_activities (
    mood_entry_id BIGINT NOT NULL,
    activity VARCHAR(50) NOT NULL,
    FOREIGN KEY (mood_entry_id) REFERENCES mood_entries(id) ON DELETE CASCADE
);

-- Create meditation_sessions table
CREATE TABLE meditation_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    notes TEXT,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create wellness_tips table
CREATE TABLE wellness_tips (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    image_url VARCHAR(500),
    read_time_minutes INT,
    is_featured BOOLEAN DEFAULT FALSE,
    user_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create professional_help table
CREATE TABLE professional_help (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    professional_name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    specialization VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    description TEXT,
    years_experience INT,
    license_number VARCHAR(100),
    consultation_fee DECIMAL(10,2),
    location VARCHAR(255),
    online_consultation BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create community_posts table
CREATE TABLE community_posts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX idx_mood_entries_created_at ON mood_entries(created_at);
CREATE INDEX idx_mood_entries_user_date ON mood_entries(user_id, created_at);
CREATE INDEX idx_meditation_sessions_user_id ON meditation_sessions(user_id);
CREATE INDEX idx_meditation_sessions_completed_at ON meditation_sessions(completed_at);
CREATE INDEX idx_wellness_tips_category ON wellness_tips(category);
CREATE INDEX idx_wellness_tips_featured ON wellness_tips(is_featured);
CREATE INDEX idx_professional_help_type ON professional_help(type);
CREATE INDEX idx_professional_help_available ON professional_help(is_available);
CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX idx_community_posts_category ON community_posts(category);
CREATE INDEX idx_community_posts_approved ON community_posts(is_approved);
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at);