from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta

from services import db_service

analytics_bp = Blueprint('analytics', __name__)


def _parse_user_id():
    """Helper to read user_id from query params safely."""
    user_id = request.args.get('user_id')
    try:
        return int(user_id) if user_id is not None else None
    except ValueError:
        return None


@analytics_bp.route('/mood', methods=['GET'])
def mood_analytics():
    """Return daily average mood score for the last 30 days.

    Output shape for React/Chart.js:
    [ { "date": "YYYY-MM-DD", "score": <float> }, ... ]
    """
    user_id = _parse_user_id()
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    conn = db_service.get_connection()
    if not conn:
        return jsonify([])

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT DATE(timestamp) AS dt,
                   AVG(CASE
                         WHEN mood_label = 'amazing' THEN 5
                         WHEN mood_label = 'good' THEN 4
                         WHEN mood_label = 'okay' THEN 3
                         WHEN mood_label = 'struggling' THEN 2
                         WHEN mood_label = 'difficult' THEN 1
                         ELSE 3
                       END) AS score
            FROM mood_logs
            WHERE user_id = %s
              AND timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY dt
            ORDER BY dt
            """,
            (user_id,),
        )
        rows = cursor.fetchall()
        data = [
            {
                'date': row['dt'].strftime('%Y-%m-%d') if isinstance(row['dt'], datetime) else str(row['dt']),
                'score': float(row['score']) if row['score'] is not None else 0.0,
            }
            for row in rows
        ]
        return jsonify(data)
    finally:
        cursor.close()
        conn.close()


@analytics_bp.route('/stress', methods=['GET'])
def stress_analytics():
    """Return daily average stress level (0-100) for last 30 days.

    Output: [ { "date": "YYYY-MM-DD", "level": <float> }, ... ]
    """
    user_id = _parse_user_id()
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    conn = db_service.get_connection()
    if not conn:
        return jsonify([])

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT DATE(timestamp) AS dt, AVG(stress_level) AS level
            FROM stress_logs
            WHERE user_id = %s
              AND timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY dt
            ORDER BY dt
            """,
            (user_id,),
        )
        rows = cursor.fetchall()



        if not rows:
            try:
                from services.stress_service import stress_service

                stress_data = stress_service.calculate_stress_level(user_id)
                stress_service.save_stress_log(user_id, stress_data)

                cursor.execute(
                    """
                    SELECT DATE(timestamp) AS dt, AVG(stress_level) AS level
                    FROM stress_logs
                    WHERE user_id = %s
                      AND timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
                    GROUP BY dt
                    ORDER BY dt
                    """,
                    (user_id,),
                )
                rows = cursor.fetchall()
            except Exception as e:
                print('⚠️ stress_analytics auto-calc failed:', e)
        data = [
            {
                'date': row['dt'].strftime('%Y-%m-%d') if isinstance(row['dt'], datetime) else str(row['dt']),
                'level': float(row['level']) if row['level'] is not None else 0.0,
            }
            for row in rows
        ]
        return jsonify(data)
    finally:
        cursor.close()
        conn.close()


@analytics_bp.route('/chat-sentiment', methods=['GET'])
def chat_sentiment_analytics():
    """Return positive/neutral/negative chat sentiment percentages for 30 days.

    Output: { "positive": x, "neutral": y, "negative": z }
    """
    user_id = _parse_user_id()
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    conn = db_service.get_connection()
    if not conn:
        return jsonify({'positive': 0, 'neutral': 0, 'negative': 0})

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT emotion_detected
            FROM chat_history
            WHERE user_id = %s
              AND timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
            """,
            (user_id,),
        )
        rows = cursor.fetchall()
        pos = neg = neu = 0
        for row in rows:
            label = (row.get('emotion_detected') or '').strip().lower()
            if not label:
                neu += 1
                continue
            if label in {'joy', 'love', 'surprise', 'happy'}:
                pos += 1
            elif label in {'sad', 'sadness', 'fear', 'anger', 'angry'}:
                neg += 1
            else:
                neu += 1

        total = pos + neg + neu
        if total == 0:
            return jsonify({'positive': 0, 'neutral': 0, 'negative': 0})

        return jsonify(
            {
                'positive': round(pos * 100.0 / total, 1),
                'neutral': round(neu * 100.0 / total, 1),
                'negative': round(neg * 100.0 / total, 1),
            }
        )
    finally:
        cursor.close()
        conn.close()


@analytics_bp.route('/face-detections', methods=['GET'])
def face_detections_analytics():
    """Return a summary of face detection logs for the user."""
    user_id = _parse_user_id()
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    stats = db_service.get_face_detection_summary(user_id)
    return jsonify(stats), 200


@analytics_bp.route('/face-detections/logs', methods=['GET'])
def face_detections_logs():
    """Return recent face detection log rows for the user.

    Query params:
      - user_id (required)
      - limit (optional, default 50)
      - days (optional, default 30)
    """
    user_id = _parse_user_id()
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    try:
        limit = int(request.args.get('limit', 50))
    except ValueError:
        limit = 50
    try:
        days = int(request.args.get('days', 30))
    except ValueError:
        days = 30

    rows = db_service.get_face_detection_logs(user_id, limit=limit, days=days)

    out = []
    for r in rows:
        ts = r.get('timestamp')
        if isinstance(ts, datetime):
            r = dict(r)
            r['timestamp'] = ts.isoformat()
        out.append(r)
    return jsonify({'data': out}), 200


@analytics_bp.route('/activity', methods=['GET'])
def activity_analytics():
    """Return activity counts over last 30 days.

    Output: [ { "type": "Exercise", "count": 12 }, ... ]
    """
    user_id = _parse_user_id()
    if not user_id:
        return jsonify({'error': 'user_id required'}), 400

    conn = db_service.get_connection()
    if not conn:
        return jsonify([])

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT activity_type, COUNT(*) AS count
            FROM activity_logs
            WHERE user_id = %s
              AND timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY activity_type
            ORDER BY count DESC
            """,
            (user_id,),
        )
        rows = cursor.fetchall()


        if not rows:
            try:
                inserted = db_service.backfill_activity_logs_from_mood_logs(user_id, days=30)
                if inserted:
                    cursor.execute(
                        """
                        SELECT activity_type, COUNT(*) AS count
                        FROM activity_logs
                        WHERE user_id = %s
                          AND timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
                        GROUP BY activity_type
                        ORDER BY count DESC
                        """,
                        (user_id,),
                    )
                    rows = cursor.fetchall()
            except Exception as e:
                print('⚠️ activity_analytics backfill failed:', e)

        data = [
            {
                'type': row['activity_type'] or 'Unknown',
                'count': int(row['count'] or 0),
            }
            for row in rows
        ]
        return jsonify(data)
    finally:
        cursor.close()
        conn.close()
