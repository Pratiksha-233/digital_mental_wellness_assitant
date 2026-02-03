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
