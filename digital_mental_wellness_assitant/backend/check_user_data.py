#!/usr/bin/env python3
"""Check user data and calculate stress for each user."""

import sys
sys.path.insert(0, '.')

from services.db_service import get_connection
from services.stress_service import stress_service

def check_user_data():
    """Display user data and calculate stress for each user."""
    conn = get_connection()
    if not conn:
        print("❌ Failed to connect to database")
        return
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Get all users
        cursor.execute('SELECT user_id, email, name FROM users')
        users = cursor.fetchall()
        
        if not users:
            print("⚠️ No users found in database")
            return
        
        print("=" * 80)
        print("USERS AND THEIR STRESS LEVELS")
        print("=" * 80)
        
        for user in users:
            user_id = user['user_id']
            email = user['email']
            name = user['name']
            
            # Get data counts for this user
            cursor.execute('SELECT COUNT(*) as cnt FROM mood_logs WHERE user_id = %s', (user_id,))
            mood_count = cursor.fetchone()['cnt']
            
            cursor.execute('SELECT COUNT(*) as cnt FROM journal_entries WHERE user_id = %s', (user_id,))
            journal_count = cursor.fetchone()['cnt']
            
            cursor.execute('SELECT COUNT(*) as cnt FROM activity_logs WHERE user_id = %s', (user_id,))
            activity_count = cursor.fetchone()['cnt']
            
            # Calculate stress
            stress_data = stress_service.calculate_stress_level(user_id)
            
            print(f"\nUser ID: {user_id} | Name: {name} | Email: {email}")
            print(f"  Data: {mood_count} mood logs | {journal_count} journal entries | {activity_count} activities")
            print(f"  Stress Level: {stress_data['stress_level']} ({stress_data['stress_category']})")
            print(f"  Primary Emotion: {stress_data['primary_emotion']}")
            print(f"  Energy Level: {stress_data['energy_level']}/10")
            print(f"  Mood Pattern: {stress_data['mood_pattern']}")
            print(f"  Component Scores: {stress_data['component_scores']}")
            print(f"  Top Factors: {stress_data['contributing_factors']}")
        
        print("\n" + "=" * 80)
        
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    check_user_data()
