"""Stress Level Calculation Service

This service computes customer stress levels based on:
1. Detected emotions (from text & face)
2. Mood patterns and trends
3. Energy levels
4. Activity frequency
5. Historical data analysis
"""

try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    np = None
from datetime import datetime, timedelta
from mysql.connector import Error
from . import db_service


class StressCalculationService:
    """Calculate stress level (0-100) based on various wellness indicators."""


    EMOTION_STRESS_WEIGHTS = {
        'anger': 85,
        'fear': 90,
        'anxiety': 88,
        'sadness': 75,
        'disgust': 70,
        'neutral': 30,
        'surprise': 40,
        'happy': 15,
        'joy': 10,
        'love': 5,
        'calm': 10,
        'relaxed': 5
    }


    MOOD_STRESS_WEIGHTS = {
        'anxious': 90,
        'stressed': 85,
        'overwhelmed': 95,
        'worried': 80,
        'tense': 75,
        'frustrated': 70,
        'irritable': 65,
        'nervous': 75,
        'sad': 60,
        'lonely': 55,
        'neutral': 30,
        'calm': 15,
        'peaceful': 10,
        'happy': 20,
        'excited': 25,
        'energetic': 20,
        'relaxed': 5
    }

    def __init__(self):
        """Initialize stress calculation service."""
        pass

    def calculate_stress_level(self, user_id: int) -> dict:
        """
        Calculate comprehensive stress level for a user.

        Args:
            user_id: User identifier

        Returns:
            dict with keys:
                - stress_level: 0-100 float
                - stress_category: 'LOW', 'MODERATE', 'HIGH', 'CRITICAL'
                - primary_emotion: Most detected emotion
                - energy_level: Average energy level
                - mood_pattern: Recent mood trend
                - contributing_factors: List of main factors
                - recommendations: Stress management suggestions
        """


        emotion_score = self._get_emotion_stress_score(user_id)
        mood_score = self._get_mood_stress_score(user_id)
        energy_score = self._get_energy_stress_score(user_id)
        activity_score = self._get_activity_stress_score(user_id)
        trend_score = self._get_trend_stress_score(user_id)


        stress_level = (
            emotion_score * 0.35 +
            mood_score * 0.25 +
            energy_score * 0.15 +
            activity_score * 0.15 +
            trend_score * 0.10
        )


        stress_level = max(0, min(100, stress_level))


        stress_category = self._categorize_stress(stress_level)


        primary_emotion = self._get_primary_emotion(user_id)


        avg_energy = self._get_average_energy(user_id)


        mood_pattern = self._get_mood_trend(user_id)


        factors = self._get_contributing_factors(
            emotion_score, mood_score, energy_score,
            activity_score, trend_score
        )


        recommendations = self._get_stress_recommendations(stress_category, primary_emotion)

        return {
            'stress_level': round(stress_level, 2),
            'stress_category': stress_category,
            'primary_emotion': primary_emotion,
            'energy_level': avg_energy,
            'mood_pattern': mood_pattern,
            'contributing_factors': factors,
            'recommendations': recommendations,
            'component_scores': {
                'emotion_score': round(emotion_score, 2),
                'mood_score': round(mood_score, 2),
                'energy_score': round(energy_score, 2),
                'activity_score': round(activity_score, 2),
                'trend_score': round(trend_score, 2)
            }
        }

    def _get_emotion_stress_score(self, user_id: int) -> float:
        """Calculate stress score from detected emotions (0-100)."""
        conn = db_service.get_connection()
        if not conn:
            return 50.0

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT predicted_emotion FROM journal_entries
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
                ORDER BY timestamp DESC LIMIT 30
            """, (user_id,))

            emotions = cursor.fetchall()

            if not emotions:
                return 50.0


            stress_scores = []
            for row in emotions:
                emotion = str(row['predicted_emotion']).lower()
                weight = self.EMOTION_STRESS_WEIGHTS.get(emotion, 50)
                stress_scores.append(weight)


            cursor.execute("""
                SELECT emotion_detected FROM chat_history
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
                ORDER BY timestamp DESC LIMIT 20
            """, (user_id,))

            face_emotions = cursor.fetchall()
            for row in face_emotions:
                if row['emotion_detected']:
                    emotion = str(row['emotion_detected']).lower()
                    weight = self.EMOTION_STRESS_WEIGHTS.get(emotion, 50)
                    stress_scores.append(weight)

            if NUMPY_AVAILABLE:
                avg_emotion_stress = np.mean(stress_scores) if stress_scores else 50.0
            else:
                avg_emotion_stress = sum(stress_scores) / len(stress_scores) if stress_scores else 50.0
            return float(avg_emotion_stress)

        except Error as e:
            print(f"Error getting emotion stress score: {e}")
            return 50.0
        finally:
            cursor.close()
            conn.close()

    def _get_mood_stress_score(self, user_id: int) -> float:
        """Calculate stress score from mood logs (0-100)."""
        conn = db_service.get_connection()
        if not conn:
            return 50.0

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT mood_label, energy_level FROM mood_logs
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
                ORDER BY timestamp DESC LIMIT 30
            """, (user_id,))

            moods = cursor.fetchall()

            if not moods:
                return 50.0


            mood_stress_scores = []
            for row in moods:
                mood = str(row['mood_label']).lower()
                weight = self.MOOD_STRESS_WEIGHTS.get(mood, 50)
                mood_stress_scores.append(weight)

            if NUMPY_AVAILABLE:
                avg_mood_stress = np.mean(mood_stress_scores) if mood_stress_scores else 50.0
            else:
                avg_mood_stress = sum(mood_stress_scores) / len(mood_stress_scores) if mood_stress_scores else 50.0
            return float(avg_mood_stress)

        except Error as e:
            print(f"Error getting mood stress score: {e}")
            return 50.0
        finally:
            cursor.close()
            conn.close()

    def _get_energy_stress_score(self, user_id: int) -> float:
        """Calculate stress based on energy levels (inverted: low energy = high stress)."""
        conn = db_service.get_connection()
        if not conn:
            return 50.0

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT AVG(energy_level) as avg_energy FROM mood_logs
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
            """, (user_id,))

            result = cursor.fetchone()
            avg_energy = result['avg_energy'] if result and result['avg_energy'] else 5



            energy_stress = (10 - avg_energy) * 10 if avg_energy else 50
            energy_stress = max(0, min(100, energy_stress))

            return float(energy_stress)

        except Error as e:
            print(f"Error getting energy stress score: {e}")
            return 50.0
        finally:
            cursor.close()
            conn.close()

    def _get_activity_stress_score(self, user_id: int) -> float:
        """Calculate stress based on activity frequency (low activity = high stress)."""
        conn = db_service.get_connection()
        if not conn:
            return 50.0

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT COUNT(*) as activity_count FROM activity_logs
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
            """, (user_id,))

            result = cursor.fetchone()
            activity_count = result['activity_count'] if result else 0



            baseline = 50
            if activity_count >= baseline:
                activity_stress = 20
            elif activity_count >= baseline * 0.5:
                activity_stress = 50
            else:
                activity_stress = 80

            return float(activity_stress)

        except Error as e:
            print(f"Error getting activity stress score: {e}")
            return 50.0
        finally:
            cursor.close()
            conn.close()

    def _get_trend_stress_score(self, user_id: int) -> float:
        """Calculate stress based on trend (worsening = high stress)."""
        conn = db_service.get_connection()
        if not conn:
            return 50.0

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT
                    CASE WHEN
                        (SELECT AVG(energy_level) FROM mood_logs
                         WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)) <
                        (SELECT AVG(energy_level) FROM mood_logs
                         WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 14 DAY)
                         AND timestamp <= DATE_SUB(NOW(), INTERVAL 7 DAY))
                    THEN 'worsening'
                    WHEN
                        (SELECT AVG(energy_level) FROM mood_logs
                         WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)) >
                        (SELECT AVG(energy_level) FROM mood_logs
                         WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 14 DAY)
                         AND timestamp <= DATE_SUB(NOW(), INTERVAL 7 DAY))
                    THEN 'improving'
                    ELSE 'stable'
                    END as trend
            """, (user_id, user_id, user_id, user_id))

            result = cursor.fetchone()
            trend = result['trend'] if result else 'stable'


            trend_map = {'worsening': 70, 'stable': 50, 'improving': 30}
            trend_stress = trend_map.get(trend, 50)

            return float(trend_stress)

        except Error as e:
            print(f"Error getting trend stress score: {e}")
            return 50.0
        finally:
            cursor.close()
            conn.close()

    def _categorize_stress(self, stress_level: float) -> str:
        """Categorize stress level into categories."""
        if stress_level < 25:
            return 'LOW'
        elif stress_level < 50:
            return 'MODERATE'
        elif stress_level < 75:
            return 'HIGH'
        else:
            return 'CRITICAL'

    def _get_primary_emotion(self, user_id: int) -> str:
        """Get most frequently detected emotion."""
        conn = db_service.get_connection()
        if not conn:
            return 'Unknown'

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT predicted_emotion, COUNT(*) as count FROM journal_entries
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
                GROUP BY predicted_emotion
                ORDER BY count DESC
                LIMIT 1
            """, (user_id,))

            result = cursor.fetchone()
            return result['predicted_emotion'].strip() if result else 'Neutral'

        except Error as e:
            print(f"Error getting primary emotion: {e}")
            return 'Unknown'
        finally:
            cursor.close()
            conn.close()

    def _get_average_energy(self, user_id: int) -> int:
        """Get average energy level (0-10)."""
        conn = db_service.get_connection()
        if not conn:
            return 5

        try:
            cursor = conn.cursor(dictionary=True)

            cursor.execute("""
                SELECT AVG(energy_level) as avg_energy FROM mood_logs
                WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)
            """, (user_id,))

            result = cursor.fetchone()
            avg_energy = int(result['avg_energy']) if result and result['avg_energy'] else 5
            return max(0, min(10, avg_energy))

        except Error as e:
            print(f"Error getting average energy: {e}")
            return 5
        finally:
            cursor.close()
            conn.close()

    def _get_mood_trend(self, user_id: int) -> str:
        """Get recent mood trend (improving, stable, declining)."""
        conn = db_service.get_connection()
        if not conn:
            return 'stable'

        try:
            cursor = conn.cursor(dictionary=True)


            cursor.execute("""
                SELECT
                    (SELECT AVG(energy_level) FROM mood_logs
                     WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)) as this_week,
                    (SELECT AVG(energy_level) FROM mood_logs
                     WHERE user_id = %s AND timestamp > DATE_SUB(NOW(), INTERVAL 14 DAY)
                     AND timestamp <= DATE_SUB(NOW(), INTERVAL 7 DAY)) as last_week
            """, (user_id, user_id))

            result = cursor.fetchone()
            if result and result['this_week'] and result['last_week']:
                diff = result['this_week'] - result['last_week']
                if diff > 1:
                    return 'improving'
                elif diff < -1:
                    return 'declining'

            return 'stable'

        except Error as e:
            print(f"Error getting mood trend: {e}")
            return 'stable'
        finally:
            cursor.close()
            conn.close()

    def _get_contributing_factors(self, emotion_score: float, mood_score: float,
                                   energy_score: float, activity_score: float,
                                   trend_score: float) -> list:
        """Identify top contributing factors to stress."""
        factors = [
            ('Emotions', emotion_score),
            ('Mood', mood_score),
            ('Energy Levels', energy_score),
            ('Activity', activity_score),
            ('Trend', trend_score)
        ]


        factors.sort(key=lambda x: x[1], reverse=True)
        return [
            {'factor': f[0], 'contribution': round(f[1], 2)}
            for f in factors[:3]
        ]

    def _get_stress_recommendations(self, stress_category: str,
                                     primary_emotion: str) -> list:
        """Get stress management recommendations based on category and emotion."""

        recommendations = {
            'LOW': [
                'Great job! Keep maintaining your current wellness routine.',
                'Continue regular physical activity and self-care practices.',
                'Stay connected with friends and family.'
            ],
            'MODERATE': [
                'Consider adding relaxation techniques like meditation or deep breathing.',
                'Increase physical activity - even 20 minutes of walking can help.',
                'Try journaling to process your emotions.',
                'Ensure you\'re getting 7-8 hours of sleep.'
            ],
            'HIGH': [
                'Practice daily meditation or mindfulness (10-15 minutes).',
                'Engage in regular exercise to reduce stress hormones.',
                'Talk to someone you trust about your feelings.',
                'Limit caffeine and alcohol consumption.',
                'Try progressive muscle relaxation or yoga.'
            ],
            'CRITICAL': [
                '⚠️ Urgent: Please reach out to a mental health professional.',
                'Call a mental health hotline if you need immediate support.',
                'Consider taking a mental health day to rest.',
                'Engage in grounding techniques: 5 senses exercise.',
                'Contact a therapist or counselor as soon as possible.',
                'Practice basic self-care: eat well, sleep, stay hydrated.'
            ]
        }


        emotion_recs = {
            'anger': 'Try calming techniques like cold water on your face or intense exercise.',
            'fear': 'Practice grounding exercises and challenge anxious thoughts.',
            'anxiety': 'Deep breathing: inhale for 4, hold for 4, exhale for 6 counts.',
            'sadness': 'Reach out to friends/family, get sunlight, do enjoyable activities.',
        }

        recs = recommendations.get(stress_category, recommendations['MODERATE'])


        emotion_lower = str(primary_emotion).lower()
        for emotion_key, emotion_rec in emotion_recs.items():
            if emotion_key in emotion_lower:
                recs.append(emotion_rec)
                break

        return recs

    def save_stress_log(self, user_id: int, stress_data: dict) -> bool:
        """Save stress calculation to database for historical tracking.

        This is idempotent per user per day: if a row already exists for today,
        we update the latest row instead of inserting a duplicate.
        """
        conn = db_service.get_connection()
        if not conn:
            print("⚠️ Could not save stress log — DB connection failed.")
            return False

        try:
            cursor = conn.cursor(dictionary=True)

            cursor.execute(
                """
                SELECT stress_id
                FROM stress_logs
                WHERE user_id = %s AND DATE(timestamp) = CURDATE()
                ORDER BY timestamp DESC
                LIMIT 1
                """,
                (user_id,),
            )
            existing = cursor.fetchone()

            if existing and existing.get('stress_id'):
                sql = """
                    UPDATE stress_logs
                    SET stress_level = %s,
                        stress_category = %s,
                        primary_emotion = %s,
                        energy_level = %s,
                        mood_pattern = %s
                    WHERE stress_id = %s
                """
                cursor.execute(
                    sql,
                    (
                        stress_data.get('stress_level'),
                        stress_data.get('stress_category'),
                        stress_data.get('primary_emotion'),
                        stress_data.get('energy_level'),
                        stress_data.get('mood_pattern'),
                        existing['stress_id'],
                    ),
                )
            else:
                sql = """
                    INSERT INTO stress_logs
                    (user_id, stress_level, stress_category, primary_emotion,
                     energy_level, mood_pattern)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """
                cursor.execute(
                    sql,
                    (
                        user_id,
                        stress_data.get('stress_level'),
                        stress_data.get('stress_category'),
                        stress_data.get('primary_emotion'),
                        stress_data.get('energy_level'),
                        stress_data.get('mood_pattern'),
                    ),
                )

            conn.commit()
            print("✅ Stress log saved successfully.")
            return True
        except Exception as e:
            print(f"❌ Error saving stress log: {e}")
            return False
        finally:
            cursor.close()
            conn.close()



stress_service = StressCalculationService()
