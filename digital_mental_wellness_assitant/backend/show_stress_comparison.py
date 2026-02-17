#!/usr/bin/env python3
"""Show stress levels for key users (1-4) with diverse data."""

import sys
sys.path.insert(0, '.')
from services.db_service import get_connection
from services.stress_service import stress_service

conn = get_connection()
c = conn.cursor(dictionary=True)

# Focus on key users with diverse data
user_ids = [1, 2, 3, 4]

print("\n" + "="*80)
print("STRESS LEVELS WITH DIVERSE USER DATA")
print("="*80)

for user_id in user_ids:
    # Get user info
    c.execute('SELECT name, email FROM users WHERE user_id = %s', (user_id,))
    user = c.fetchone()
    
    if not user:
        continue
    
    # Count data
    c.execute('SELECT COUNT(*) as cnt FROM mood_logs WHERE user_id = %s', (user_id,))
    mood_cnt = c.fetchone()['cnt']
    
    c.execute('SELECT COUNT(*) as cnt FROM journal_entries WHERE user_id = %s', (user_id,))
    journal_cnt = c.fetchone()['cnt']
    
    c.execute('SELECT COUNT(*) as cnt FROM activity_logs WHERE user_id = %s', (user_id,))
    activity_cnt = c.fetchone()['cnt']
    
    # Get energy levels for display
    c.execute('SELECT energy_level FROM mood_logs WHERE user_id = %s ORDER BY timestamp DESC LIMIT 7', (user_id,))
    energies = [str(e['energy_level']) for e in c.fetchall()]
    
    # Calculate stress
    stress = stress_service.calculate_stress_level(user_id)
    
    print(f"\n📊 User ID: {user_id}")
    print(f"   Name: {user['name']} | Email: {user['email']}")
    print(f"   Data: {mood_cnt} mood logs | {journal_cnt} journal entries | {activity_cnt} activities")
    print(f"   Energy Levels: {', '.join(energies)}")
    print(f"   ⛔ STRESS LEVEL: {stress['stress_level']}/100 ({stress['stress_category']})")
    print(f"   Primary Emotion: {stress['primary_emotion']}")
    print(f"   Mood Pattern: {stress['mood_pattern']}")
    print(f"\n   Component Breakdown:")
    for key, val in stress['component_scores'].items():
        print(f"     {key}: {val}")

print("\n" + "="*80)
c.close()
conn.close()
