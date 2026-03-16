import sys
from pathlib import Path
import mysql.connector
from mysql.connector import Error

# Import `config` robustly: prefer absolute import when running as a script,
# otherwise fall back to package-relative import when running as a package.
try:
    import config
except Exception:
    try:
        from .. import config
    except Exception:
        # As a last resort, ensure backend package root is on sys.path then import
        sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
        import config



def get_connection():
    """Create and return a configured MySQL connection.

    Returns a mysql.connector connection or None on failure.
    """
    try:
        conn = mysql.connector.connect(
            host=config.DB_CONFIG.get('host', 'localhost'),
            user=config.DB_CONFIG.get('user', 'root'),
            password=config.DB_CONFIG.get('password', 'Pra@#ti825'),
            database=config.DB_CONFIG.get('database', 'mental_wellness'),
            port=config.DB_CONFIG.get('port', 3306),
            charset=config.DB_CONFIG.get('charset', 'utf8mb4')
        )
        if conn.is_connected():
            conn.autocommit = config.DB_CONFIG.get('autocommit', False)
            return conn
        else:
            print("❌ Database connection failed.")
            return None
    except Error as e:
        print("❌ DB connection error:", e)
        return None


# helper: insert a journal (text) entry with predicted emotion
def insert_journal_entry(user_id, text_entry, predicted_emotion):
    conn = get_connection()
    if not conn:
        print("⚠️ Could not insert journal entry — DB connection failed.")
        return False, 'db_connection_failed'
    try:
        cursor = conn.cursor()
        sql = """
            INSERT INTO journal_entries (user_id, text_entry, predicted_emotion)
            VALUES (%s, %s, %s)
        """
        cursor.execute(sql, (user_id, text_entry, predicted_emotion))
        conn.commit()
        print("🧠 Journal entry inserted successfully.")
        return True, None
    except Error as e:
        print("❌ Insert journal entry error:", e)
        return False, str(e)
    finally:
        cursor.close()
        conn.close()


def insert_chat_message(user_id, user_message, bot_response, emotion_detected):
    """Insert a chatbot interaction into chat_history.

    Only fields defined in the schema are stored; richer
    analysis (sentiment, crisis flags, intents) is returned
    to the client but not persisted.
    """
    conn = get_connection()
    if not conn:
        print("⚠️ Could not insert chat message — DB connection failed.")
        return False, 'db_connection_failed'

    try:
        cursor = conn.cursor()
        sql = """
            INSERT INTO chat_history (user_id, user_message, bot_response, emotion_detected)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(sql, (user_id, user_message, bot_response, emotion_detected))
        conn.commit()
        print("💬 Chat message inserted into chat_history.")
        return True, None
    except Error as e:
        err = str(e)
        print("❌ Insert chat message error:", err)
        return False, err
    finally:
        cursor.close()
        conn.close()


# insert a structured mood log including mood label, energy, activities, and note
def insert_mood_log(user_id, mood_label, energy_level, activities, note):
    conn = get_connection()
    if not conn:
        print("⚠️ Could not insert mood log — DB connection failed.")
        return False, 'db_connection_failed'
    try:
        cursor = conn.cursor()
        sql = """
            INSERT INTO mood_logs (user_id, mood_label, energy_level, activities, note)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(sql, (user_id, mood_label, energy_level, activities, note))
        conn.commit()
        print("🧾 Structured mood log inserted successfully.")
        return True, None
    except Error as e:
        err = str(e)
        print("❌ Insert structured mood log error:", err)
        return False, err
    finally:
        cursor.close()
        conn.close()


    


def get_mood_logs_by_user(user_id):
    conn = get_connection()
    if not conn:
        print("⚠️ DB connection failed when fetching mood logs.")
        return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT log_id, user_id, mood_label, energy_level, activities, note, timestamp FROM mood_logs WHERE user_id = %s ORDER BY timestamp DESC", (user_id,))
        rows = cursor.fetchall()
        return rows
    except Error as e:
        print("❌ get_mood_logs_by_user error:", e)
        return []
    finally:
        cursor.close()
        conn.close()


def get_journal_entries_by_user(user_id):
    conn = get_connection()
    if not conn:
        print("⚠️ DB connection failed when fetching journal entries.")
        return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT entry_id, user_id, text_entry, predicted_emotion, timestamp FROM journal_entries WHERE user_id = %s ORDER BY timestamp DESC", (user_id,))
        rows = cursor.fetchall()
        return rows
    except Error as e:
        print("❌ get_journal_entries_by_user error:", e)
        return []
    finally:
        cursor.close()
        conn.close()


def get_or_create_user_by_email(email, name=None):
    conn = get_connection()
    if not conn:
        print("⚠️ DB connection failed while resolving user by email.")
        return None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT user_id FROM users WHERE email = %s", (email,))
        row = cursor.fetchone()
        if row:
            return row['user_id']
        # create a new user with minimal info
        insert_cursor = conn.cursor()
        sql = "INSERT INTO users (name, email) VALUES (%s, %s)"
        insert_cursor.execute(sql, (name or 'User', email))
        conn.commit()
        new_id = insert_cursor.lastrowid
        insert_cursor.close()
        print(f"🔑 Created new user {new_id} for email={email}")
        return new_id
    except Error as e:
        print("❌ get_or_create_user_by_email error:", e)
        return None
    finally:
        cursor.close()
        conn.close()



# helper: fetch recommendations
def get_recommendation_for(emotion):
    conn = get_connection()
    if not conn:
        print("⚠️ Could not fetch recommendations — DB connection failed.")
        return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT suggestion_text, resource_link 
            FROM recommendations 
            WHERE emotion_type = %s
        """, (emotion,))
        rows = cursor.fetchall()
        print(f"💡 {len(rows)} recommendations fetched for emotion: {emotion}")
        return rows
    except Error as e:
        print("❌ Recommendation query error:", e)
        return []
    finally:
        cursor.close()
        conn.close()


def get_user_progress(user_id):
    """Return progress counts for a user:
    - mood_checkins: count of rows in mood_logs
    - journal_entries: count of rows in journal_entries
    - days_active: count of distinct dates with any activity across mood_logs, journal_entries, chat_history, activity_logs
    """
    conn = get_connection()
    if not conn:
        print("⚠️ DB connection failed when computing user progress.")
        return {'mood_checkins': 0, 'journal_entries': 0, 'days_active': 0}

    try:
        cursor = conn.cursor()

        # mood checkins
        cursor.execute("SELECT COUNT(*) FROM mood_logs WHERE user_id = %s", (user_id,))
        mood_count = cursor.fetchone()[0] or 0

        # journal entries
        cursor.execute("SELECT COUNT(*) FROM journal_entries WHERE user_id = %s", (user_id,))
        journal_count = cursor.fetchone()[0] or 0

        # days active: distinct dates across several tables
        sql_days = """
            SELECT COUNT(DISTINCT dt) FROM (
                SELECT DATE(timestamp) as dt FROM mood_logs WHERE user_id = %s
                UNION ALL
                SELECT DATE(timestamp) as dt FROM journal_entries WHERE user_id = %s
                UNION ALL
                SELECT DATE(timestamp) as dt FROM chat_history WHERE user_id = %s
                UNION ALL
                SELECT DATE(timestamp) as dt FROM activity_logs WHERE user_id = %s
            ) t
        """
        cursor.execute(sql_days, (user_id, user_id, user_id, user_id))
        days_active = cursor.fetchone()[0] or 0

        return {
            'mood_checkins': int(mood_count),
            'journal_entries': int(journal_count),
            'days_active': int(days_active)
        }

    except Error as e:
        print("❌ get_user_progress error:", e)
        return {'mood_checkins': 0, 'journal_entries': 0, 'days_active': 0}
    finally:
        cursor.close()
        conn.close()


def insert_face_detection_log(user_id, detected_emotion, confidence_score, faces_detected, detection_method='image'):
    """Insert a face detection log into face_detection_logs table."""
    conn = get_connection()
    if not conn:
        print("⚠️ Could not insert face detection log — DB connection failed.")
        return False, 'db_connection_failed'
    try:
        cursor = conn.cursor()
        sql = """
            INSERT INTO face_detection_logs (user_id, detected_emotion, confidence_score, faces_detected, detection_method)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(sql, (user_id, detected_emotion, confidence_score, faces_detected, detection_method))
        conn.commit()
        print("📸 Face detection log inserted successfully.")
        return True, None
    except Error as e:
        err = str(e)
        print("❌ Insert face detection log error:", err)
        return False, err
    finally:
        cursor.close()
        conn.close()


def get_face_detection_summary(user_id, days=30):
    """Return summary counts and average confidence for face detection logs."""
    conn = get_connection()
    if not conn:
        print("⚠️ Could not fetch face detection summary — DB connection failed.")
        return {
            'total': 0,
            'by_emotion': {},
            'avg_confidence': 0.0,
        }

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT
                COALESCE(detected_emotion, 'Unknown') AS emotion,
                COUNT(*) AS count,
                AVG(confidence_score) AS avg_confidence
            FROM face_detection_logs
            WHERE user_id = %s
              AND timestamp > DATE_SUB(NOW(), INTERVAL %s DAY)
            GROUP BY emotion
            ORDER BY count DESC
            """,
            (user_id, days),
        )
        rows = cursor.fetchall()

        total = sum(int(r.get('count') or 0) for r in rows)
        by_emotion = {r.get('emotion') or 'Unknown': int(r.get('count') or 0) for r in rows}
        weighted_sum = sum(
            (float(r.get('avg_confidence') or 0.0) * int(r.get('count') or 0)) for r in rows
        )
        avg_confidence = float(weighted_sum / total) if total > 0 else 0.0

        return {
            'total': total,
            'by_emotion': by_emotion,
            'avg_confidence': avg_confidence,
        }
    except Error as e:
        print("❌ get_face_detection_summary error:", e)
        return {
            'total': 0,
            'by_emotion': {},
            'avg_confidence': 0.0,
        }
    finally:
        cursor.close()
        conn.close()
