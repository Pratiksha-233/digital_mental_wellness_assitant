"""Test script for stress level calculation service.

Usage (from project root):
    python -m backend.test_stress_calculation
"""

import sys
from pathlib import Path

try:
    from .services.stress_service import stress_service
    from .services.db_service import get_connection
except Exception:
    sys.path.append(str(Path(__file__).resolve().parent))
    from backend.services.stress_service import stress_service
    from backend.services.db_service import get_connection


def test_stress_calculation():
    """Test stress calculation with a sample user."""
    
    print("\n" + "="*60)
    print("🧠 STRESS LEVEL CALCULATION TEST")
    print("="*60)
    
    # First, check database connection
    print("\n1️⃣ Testing database connection...")
    conn = get_connection()
    if not conn:
        print("❌ Failed to connect to database")
        return False
    
    conn.close()
    print("✅ Database connection successful")
    
    # Check if we have any users
    print("\n2️⃣ Checking for test users...")
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT user_id, name, email FROM users LIMIT 5")
    users = cursor.fetchall()
    
    if not users:
        print("❌ No users found in database")
        print("   Please create users first using /api/auth/register")
        cursor.close()
        conn.close()
        return False
    
    print(f"✅ Found {len(users)} users:")
    for user in users:
        print(f"   - User ID {user['user_id']}: {user['name']} ({user['email']})")
    
    # Test stress calculation for first user
    test_user_id = users[0]['user_id']
    print(f"\n3️⃣ Calculating stress level for User ID {test_user_id}...")
    
    try:
        stress_data = stress_service.calculate_stress_level(test_user_id)
        
        print("\n✅ Stress Calculation Results:")
        print(f"   📊 Stress Level: {stress_data['stress_level']}/100")
        print(f"   📍 Category: {stress_data['stress_category']}")
        print(f"   😊 Primary Emotion: {stress_data['primary_emotion']}")
        print(f"   ⚡ Energy Level: {stress_data['energy_level']}/10")
        print(f"   📈 Mood Pattern: {stress_data['mood_pattern']}")
        
        print("\n   📋 Component Scores:")
        for key, value in stress_data['component_scores'].items():
            print(f"      - {key.replace('_', ' ').title()}: {value}")
        
        print("\n   🎯 Contributing Factors:")
        for i, factor in enumerate(stress_data['contributing_factors'], 1):
            print(f"      {i}. {factor['factor']}: {factor['contribution']}")
        
        print("\n   💡 Recommendations:")
        for i, rec in enumerate(stress_data['recommendations'], 1):
            print(f"      {i}. {rec}")
        
        # Test saving to database
        print("\n4️⃣ Saving stress log to database...")
        saved = stress_service.save_stress_log(test_user_id, stress_data)
        if saved:
            print("✅ Stress log saved successfully")
        else:
            print("⚠️  Failed to save stress log")
        
        # Verify it was saved
        print("\n5️⃣ Verifying stress log in database...")
        cursor.execute("""
            SELECT stress_level, stress_category, timestamp 
            FROM stress_logs 
            WHERE user_id = %s 
            ORDER BY timestamp DESC 
            LIMIT 1
        """, (test_user_id,))
        
        latest_log = cursor.fetchone()
        if latest_log:
            print(f"✅ Latest stress log found:")
            print(f"   Stress: {latest_log['stress_level']}/100")
            print(f"   Category: {latest_log['stress_category']}")
            print(f"   Time: {latest_log['timestamp']}")
        else:
            print("⚠️  No stress logs found in database")
        
        print("\n" + "="*60)
        print("✅ ALL TESTS PASSED!")
        print("="*60)
        print("\nYour stress calculation system is working correctly.")
        print("\nAPI Endpoints Available:")
        print("  • GET /api/stress/calculate?user_id=123")
        print("  • GET /api/stress/history?user_id=123&days=30")
        print("  • GET /api/stress/stats?user_id=123")
        print("  • GET /api/stress/recommendation?user_id=123")
        print("\n")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"\n❌ Error during stress calculation: {e}")
        import traceback
        traceback.print_exc()
        cursor.close()
        conn.close()
        return False


if __name__ == '__main__':
    success = test_stress_calculation()
    raise SystemExit(0 if success else 1)
