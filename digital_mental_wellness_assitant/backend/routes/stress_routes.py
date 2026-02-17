"""Stress Level API Routes

Endpoints for calculating and retrieving customer stress levels.
"""

from flask import Blueprint, request, jsonify
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from services.stress_service import stress_service

stress_bp = Blueprint('stress', __name__)


@stress_bp.route('/calculate', methods=['GET'])
def calculate_stress():
    """
    Calculate current stress level for a user.
    
    Query Parameters:
        user_id (int, required): User ID
    
    Returns:
        {
            "stress_level": 45.5,           # 0-100 scale
            "stress_category": "MODERATE",  # LOW, MODERATE, HIGH, CRITICAL
            "primary_emotion": "Anxiety",
            "energy_level": 6,              # 0-10 scale
            "mood_pattern": "stable",       # stable, improving, declining
            "contributing_factors": [
                {"factor": "Emotions", "contribution": 65.3},
                {"factor": "Mood", "contribution": 52.1},
                {"factor": "Energy Levels", "contribution": 40.0}
            ],
            "recommendations": [...]
        }
    """
    user_id = request.args.get('user_id')
    
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400
    
    try:
        user_id = int(user_id)
    except ValueError:
        return jsonify({'error': 'invalid user_id (must be integer)'}), 400
    
    try:
        # Calculate stress level
        stress_data = stress_service.calculate_stress_level(user_id)
        
        # Save to database for historical tracking
        stress_service.save_stress_log(user_id, stress_data)
        
        return jsonify({
            'status': 'success',
            'data': stress_data
        }), 200
        
    except Exception as e:
        print(f"Error calculating stress: {e}")
        return jsonify({
            'error': 'Failed to calculate stress level',
            'detail': str(e)
        }), 500


@stress_bp.route('/history', methods=['GET'])
def get_stress_history():
    """
    Get historical stress level records for a user.
    
    Query Parameters:
        user_id (int, required): User ID
        days (int, optional): Number of days to retrieve (default: 30)
        limit (int, optional): Max records (default: 100)
    
    Returns:
        [
            {
                "stress_id": 1,
                "user_id": 123,
                "stress_level": 45.5,
                "stress_category": "MODERATE",
                "primary_emotion": "Anxiety",
                "energy_level": 6,
                "mood_pattern": "stable",
                "timestamp": "2026-02-15T14:30:00"
            },
            ...
        ]
    """
    user_id = request.args.get('user_id')
    days = request.args.get('days', 30, type=int)
    limit = request.args.get('limit', 100, type=int)
    
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400
    
    try:
        user_id = int(user_id)
    except ValueError:
        return jsonify({'error': 'invalid user_id'}), 400
    
    # use absolute import via services package
    import sys
    from pathlib import Path
    sys.path.insert(0, str(Path(__file__).parent.parent))
    from services.db_service import get_connection
    from mysql.connector import Error
    
    conn = get_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        sql = """
            SELECT 
                stress_id, user_id, stress_level, stress_category,
                primary_emotion, energy_level, mood_pattern, timestamp
            FROM stress_logs
            WHERE user_id = %s 
            AND timestamp > DATE_SUB(NOW(), INTERVAL %s DAY)
            ORDER BY timestamp DESC
            LIMIT %s
        """
        
        cursor.execute(sql, (user_id, days, limit))
        records = cursor.fetchall()
        
        # Convert datetime objects to ISO format strings
        for record in records:
            if isinstance(record['timestamp'], object):
                record['timestamp'] = record['timestamp'].isoformat()
        
        return jsonify({
            'status': 'success',
            'count': len(records),
            'data': records
        }), 200
        
    except Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Failed to retrieve history'}), 500
    finally:
        cursor.close()
        conn.close()


@stress_bp.route('/stats', methods=['GET'])
def get_stress_stats():
    """
    Get stress statistics and trends for a user.
    
    Query Parameters:
        user_id (int, required): User ID
        days (int, optional): Number of days to analyze (default: 30)
    
    Returns:
        {
            "average_stress": 45.5,
            "min_stress": 20.0,
            "max_stress": 85.0,
            "current_stress": 52.0,
            "trend": "improving",
            "low_count": 5,
            "moderate_count": 12,
            "high_count": 8,
            "critical_count": 0
        }
    """
    user_id = request.args.get('user_id')
    days = request.args.get('days', 30, type=int)
    
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400
    
    try:
        user_id = int(user_id)
    except ValueError:
        return jsonify({'error': 'invalid user_id'}), 400
    
    # use absolute import via services package
    import sys
    from pathlib import Path
    sys.path.insert(0, str(Path(__file__).parent.parent))
    from services.db_service import get_connection
    from mysql.connector import Error
    import numpy as np
    
    conn = get_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Get all stress records
        sql = """
            SELECT stress_level, stress_category, timestamp
            FROM stress_logs
            WHERE user_id = %s 
            AND timestamp > DATE_SUB(NOW(), INTERVAL %s DAY)
            ORDER BY timestamp ASC
        """
        
        cursor.execute(sql, (user_id, days))
        records = cursor.fetchall()
        
        if not records:
            return jsonify({'error': 'No stress data available'}), 404
        
        stress_levels = [r['stress_level'] for r in records]
        categories = [r['stress_category'] for r in records]
        
        # Calculate statistics
        avg_stress = float(np.mean(stress_levels))
        min_stress = float(np.min(stress_levels))
        max_stress = float(np.max(stress_levels))
        current_stress = float(stress_levels[-1])  # Last recorded
        
        # Calculate trend
        if len(stress_levels) > 1:
            first_half = np.mean(stress_levels[:len(stress_levels)//2])
            second_half = np.mean(stress_levels[len(stress_levels)//2:])
            if second_half < first_half - 5:
                trend = 'improving'
            elif second_half > first_half + 5:
                trend = 'worsening'
            else:
                trend = 'stable'
        else:
            trend = 'insufficient_data'
        
        # Count categories
        category_counts = {
            'low_count': categories.count('LOW'),
            'moderate_count': categories.count('MODERATE'),
            'high_count': categories.count('HIGH'),
            'critical_count': categories.count('CRITICAL')
        }
        
        return jsonify({
            'status': 'success',
            'average_stress': round(avg_stress, 2),
            'min_stress': round(min_stress, 2),
            'max_stress': round(max_stress, 2),
            'current_stress': round(current_stress, 2),
            'trend': trend,
            'period_days': days,
            'total_records': len(records),
            **category_counts
        }), 200
        
    except Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Failed to retrieve statistics'}), 500
    finally:
        cursor.close()
        conn.close()


@stress_bp.route('/recommendation', methods=['GET'])
def get_stress_recommendation():
    """
    Get personalized stress management recommendations.
    
    Query Parameters:
        user_id (int, required): User ID
    
    Returns:
        {
            "stress_level": 45.5,
            "stress_category": "MODERATE",
            "recommendations": [
                "Practice daily meditation or mindfulness (10-15 minutes).",
                "Engage in regular exercise to reduce stress hormones.",
                ...
            ]
        }
    """
    user_id = request.args.get('user_id')
    
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400
    
    try:
        user_id = int(user_id)
    except ValueError:
        return jsonify({'error': 'invalid user_id'}), 400
    
    try:
        stress_data = stress_service.calculate_stress_level(user_id)
        
        return jsonify({
            'status': 'success',
            'stress_level': stress_data['stress_level'],
            'stress_category': stress_data['stress_category'],
            'primary_emotion': stress_data['primary_emotion'],
            'recommendations': stress_data['recommendations']
        }), 200
        
    except Exception as e:
        print(f"Error getting recommendations: {e}")
        return jsonify({
            'error': 'Failed to get recommendations',
            'detail': str(e)
        }), 500
