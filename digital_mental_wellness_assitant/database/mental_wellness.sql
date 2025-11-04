-- MySQL schema for Digital Mental Wellness Assistant
CREATE DATABASE IF NOT EXISTS mental_wellness;
USE mental_wellness;


CREATE TABLE IF NOT EXISTS users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
password_hash VARCHAR(255) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS mood_logs (
log_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT,
text_entry TEXT,
predicted_emotion VARCHAR(50),
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


-- sample recommendation rows
INSERT INTO recommendations (emotion_type, suggestion_text, resource_link) VALUES
('Anxiety', 'Try 5 minutes of deep breathing: inhale 4s, hold 4s, exhale 6s.', ''),
('Sadness', 'Take a short walk, listen to an uplifting song, or connect with a friend.', ''),
('Anger', 'Pause and count to 10. Practice grounding: name 5 things you can see.', '');