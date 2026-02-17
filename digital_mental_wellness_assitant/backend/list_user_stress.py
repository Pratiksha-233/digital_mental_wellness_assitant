#!/usr/bin/env python3
import sys
sys.path.insert(0, '.')
from services.db_service import get_connection
from services.stress_service import stress_service

conn = get_connection()
c = conn.cursor(dictionary=True)

# Get all users
c.execute('SELECT user_id, name, email FROM users')
users = c.fetchall()

print("\n" + "="*80)
print("STRESS CALCULATION FOR ALL USERS (BASED ON REAL DATABASE DATA)")
print("="*80)

for user in users:
    user_id = user['user_id']
    name = user['name']
    email = user['email']
    
    # Count data
    c.execute('SELECT COUNT(*) as cnt FROM mood_logs WHERE user_id = %s', (user_id,))
    mood_cnt = c.fetchone()['cnt']
    
    c.execute('SELECT COUNT(*) as cnt FROM journal_entries WHERE user_id = %s', (user_id,))
    journal_cnt = c.fetchone()['cnt']
    
    c.execute('SELECT COUNT(*) as cnt FROM activity_logs WHERE user_id = %s', (user_id,))
    activity_cnt = c.fetchone()['cnt']
    
    # Calculate stress
    stress = stress_service.calculate_stress_level(user_id)
    
    print(f"\nUser ID: {user_id}")
    print(f"  Name: {name}, Email: {email}")
    print(f"  Data: {mood_cnt} mood logs | {journal_cnt} journal | {activity_cnt} activities")
    print(f"  Stress Level: {stress['stress_level']}/100 ({stress['stress_category']})")
    print(f"  Primary Emotion: {stress['primary_emotion']}")
    print(f"  Energy: {stress['energy_level']}/10 | Mood: {stress['mood_pattern']}")
    print(f"  Component Scores: {stress['component_scores']}")

print("\n" + "="*80)
c.close()
conn.close()
