-- Migration: add firebase_uid to users and mood fields to mood_logs
-- Run this against your MySQL database. Replace the database name if different.

-- Option A: Run interactively with mysql client
-- 1) Open PowerShell and run:
--    mysql -u <db_user> -p -D <database_name>
-- 2) Paste the statements below and press Enter.

-- Option B: Run as a single command from PowerShell (replace user/dbname):
--    mysql -u root -p -D mental_wellness -e "ALTER TABLE users ADD COLUMN firebase_uid VARCHAR(255); ALTER TABLE users MODIFY COLUMN email VARCHAR(100) NULL; ALTER TABLE users MODIFY COLUMN password_hash VARCHAR(255) NULL; ALTER TABLE mood_logs ADD COLUMN mood_label VARCHAR(50); ALTER TABLE mood_logs ADD COLUMN energy_level INT; ALTER TABLE mood_logs ADD COLUMN activities TEXT; ALTER TABLE mood_logs ADD COLUMN note TEXT;"

-- NOTE: If any column already exists you may see an error. That's safe to ignore.

USE mental_wellness;

-- Add firebase_uid if not present
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(255);

-- Make email/password nullable (safe to re-run)
ALTER TABLE users
  MODIFY COLUMN email VARCHAR(100) NULL;

ALTER TABLE users
  MODIFY COLUMN password_hash VARCHAR(255) NULL;

-- Mood log additional fields (add if not exists)
ALTER TABLE mood_logs
  ADD COLUMN IF NOT EXISTS mood_label VARCHAR(50);

ALTER TABLE mood_logs
  ADD COLUMN IF NOT EXISTS energy_level INT;

ALTER TABLE mood_logs
  ADD COLUMN IF NOT EXISTS activities TEXT;

ALTER TABLE mood_logs
  ADD COLUMN IF NOT EXISTS note TEXT;

-- After running: restart your Flask backend (see instructions below)

-- Quick backend restart (PowerShell from project root):
--    cd backend; python app.py

-- If you still get a 500 from the app, copy the full error text shown in the backend terminal or the SnackBar in the app and paste it here so I can diagnose further.
