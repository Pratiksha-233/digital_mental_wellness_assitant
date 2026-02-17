#!/usr/bin/env python3
"""Generate diverse, realistic test data for multiple users with different stress profiles."""

import sys
sys.path.insert(0, '.')

from services.db_service import get_connection
from datetime import datetime, timedelta
import random

def generate_varied_data():
    """Generate test data for users with different stress profiles."""
    
    conn = get_connection()
    if not conn:
        print("❌ Failed to connect to database")
        return
    
    try:
        cursor = conn.cursor()
        
        # Define user profiles with different stress levels
        profiles = [
            {
                'user_id': 1,
                'name': 'High Stress User',
                'moods': [
                    ('anxious', 3),
                    ('stressed', 2),
                    ('overwhelmed', 4),
                    ('anxious', 3),
                    ('frustrated', 2),
                    ('nervous', 3),
                    ('worried', 4),
                ],
                'emotions': ['fear', 'anger', 'anxiety', 'sadness', 'anger', 'fear', 'anxiety'],
                'activities': 5
            },
            {
                'user_id': 2,
                'name': 'Moderate Stress User',
                'moods': [
                    ('neutral', 5),
                    ('calm', 6),
                    ('stressed', 3),
                    ('peaceful', 7),
                    ('neutral', 5),
                    ('calm', 6),
                    ('relaxed', 8),
                ],
                'emotions': ['neutral', 'happy', 'calm', 'neutral', 'happy', 'calm', 'peaceful'],
                'activities': 30
            },
            {
                'user_id': 3,
                'name': 'Low Stress User',
                'moods': [
                    ('happy', 9),
                    ('excited', 10),
                    ('peaceful', 8),
                    ('happy', 9),
                    ('energetic', 9),
                    ('calm', 8),
                    ('relaxed', 9),
                ],
                'emotions': ['happy', 'joy', 'happy', 'love', 'happy', 'joy', 'excited'],
                'activities': 60
            },
            {
                'user_id': 4,
                'name': 'Critical Stress User',
                'moods': [
                    ('overwhelmed', 1),
                    ('anxious', 1),
                    ('stressed', 1),
                    ('overwhelmed', 2),
                    ('lonely', 1),
                    ('sad', 1),
                    ('anxious', 1),
                ],
                'emotions': ['fear', 'sadness', 'anxiety', 'disgust', 'anxiety', 'sadness', 'fear'],
                'activities': 2
            },
        ]
        
        print("=" * 80)
        print("GENERATING DIVERSE USER DATA FOR STRESS TESTING")
        print("=" * 80)
        
        for profile in profiles:
            user_id = profile['user_id']
            mood_data = profile['moods']
            emotions = profile['emotions']
            num_activities = profile['activities']
            
            # Clear existing data for this user
            cursor.execute('DELETE FROM mood_logs WHERE user_id = %s', (user_id,))
            cursor.execute('DELETE FROM journal_entries WHERE user_id = %s', (user_id,))
            cursor.execute('DELETE FROM activity_logs WHERE user_id = %s', (user_id,))
            conn.commit()
            
            print(f"\n📊 User {user_id}: {profile['name']}")
            
            # Insert mood logs (last 7 days)
            base_time = datetime.now() - timedelta(days=7)
            for i, (mood, energy) in enumerate(mood_data):
                timestamp = base_time + timedelta(hours=i*12)
                cursor.execute("""
                    INSERT INTO mood_logs (user_id, mood_label, energy_level, timestamp)
                    VALUES (%s, %s, %s, %s)
                """, (user_id, mood, energy, timestamp))
            
            print(f"  ✅ Added {len(mood_data)} mood logs (energy levels: {[e for _, e in mood_data]})")
            
            # Insert journal entries with emotions
            for i, emotion in enumerate(emotions):
                timestamp = base_time + timedelta(hours=i*12)
                text = f"Sample journal entry {i+1} with {emotion} emotion"
                cursor.execute("""
                    INSERT INTO journal_entries (user_id, text_entry, predicted_emotion, timestamp)
                    VALUES (%s, %s, %s, %s)
                """, (user_id, text, emotion, timestamp))
            
            print(f"  ✅ Added {len(emotions)} journal entries (emotions: {emotions[:3]}...)")
            
            # Insert activity logs
            for i in range(num_activities):
                timestamp = base_time + timedelta(hours=i*2)
                activities = ['walking', 'meditation', 'exercise', 'reading', 'socializing', 'yoga', 'sports']
                activity = random.choice(activities)
                cursor.execute("""
                    INSERT INTO activity_logs (user_id, activity_type, timestamp)
                    VALUES (%s, %s, %s)
                """, (user_id, activity, timestamp))
            
            print(f"  ✅ Added {num_activities} activity logs")
        
        conn.commit()
        print("\n" + "=" * 80)
        print("✅ TEST DATA GENERATED SUCCESSFULLY")
        print("=" * 80)
        print("\nNow run: python list_user_stress.py")
        print("You should see different stress levels for each user!\n")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    generate_varied_data()
