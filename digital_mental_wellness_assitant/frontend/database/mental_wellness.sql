-- MySQL schema for Digital Mental Wellness Assistant
CREATE DATABASE IF NOT EXISTS mental_wellness;
USE mental_wellness;


CREATE TABLE IF NOT EXISTS users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NULL,
password_hash VARCHAR(255) NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS journal_entries (
	entry_id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	text_entry TEXT NOT NULL,
	predicted_emotion VARCHAR(100),
	timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS mood_logs (
	log_id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	mood_label VARCHAR(50) NOT NULL,
	energy_level INT,
	activities TEXT,
	note TEXT,
	timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS chat_history (
chat_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT,
user_message TEXT,
bot_response TEXT,
emotion_detected VARCHAR(50),
timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS recommendations (
rec_id INT AUTO_INCREMENT PRIMARY KEY,
emotion_type VARCHAR(50),
suggestion_text TEXT,
resource_link VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS activity_logs (
activity_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT,
activity_type VARCHAR(50),
timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS stress_logs (
	stress_id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	stress_level FLOAT CHECK (stress_level >= 0 AND stress_level <= 100),
	stress_category VARCHAR(50),
	primary_emotion VARCHAR(50),
	energy_level INT,
	mood_pattern TEXT,
	activity_frequency INT,
	timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
	INDEX idx_user_id (user_id),
	INDEX idx_timestamp (timestamp),
	INDEX idx_stress_level (stress_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS face_detection_logs (
    detection_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    detected_emotion VARCHAR(50),
    confidence_score FLOAT,
    faces_detected INT,
    detection_method VARCHAR(20),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
<<<<<<< HEAD
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
=======
);
>>>>>>> da066f3ed967c08f3ab04fc811d8c08a2b3b16ec
