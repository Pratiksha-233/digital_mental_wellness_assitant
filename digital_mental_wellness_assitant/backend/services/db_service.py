import sys
from pathlib import Path
from datetime import datetime, timedelta

try:
    import mysql.connector as mysql_connector  # type: ignore
    from mysql.connector import Error as MySQLError  # type: ignore
except Exception:  # pragma: no cover
    mysql_connector = None
    MySQLError = Exception

Error = MySQLError

from .sqlite_db import connect_sqlite



try:
    import config
except Exception:
    try:
        from .. import config
    except Exception:

        sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
        import config



def get_connection():
    """Create and return a configured MySQL connection.

    Returns a mysql.connector connection or None on failure.
    """
    engine = getattr(config, 'DB_ENGINE', 'mysql')
    if str(engine).lower() == 'sqlite':
        return connect_sqlite(getattr(config, 'SQLITE_PATH', 'mental_wellness.sqlite3'))

    try:
        if mysql_connector is None:
            raise ImportError('mysql-connector-python is not installed')

        conn = mysql_connector.connect(
            host=config.DB_CONFIG.get('host', 'localhost'),
            user=config.DB_CONFIG.get('user', 'root'),
            password=config.DB_CONFIG.get('password', 'mysqlworld@123'),
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
    except Exception as e:
        print("❌ DB connection error:", e)
        if getattr(config, 'SQLITE_FALLBACK', True):
            print("ℹ️ Falling back to local SQLite DB. Set DB_ENGINE=mysql and correct DB_* env vars to use MySQL.")
            try:
                return connect_sqlite(getattr(config, 'SQLITE_PATH', 'mental_wellness.sqlite3'))
            except Exception as e2:
                print("❌ SQLite fallback failed:", e2)
        return None



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


def get_chat_history_by_user(user_id: int, limit: int = 100):
    """Fetch recent chat_history rows for a user.

    Returns a list of dicts ordered oldest -> newest, with keys:
      - chat_id
      - user_id
      - user_message
      - bot_response
      - emotion_detected
      - timestamp

    Notes:
    - The underlying schema stores user + bot as a single row (pair).
    - We keep this shape for backwards compatibility and expand it in the API.
    """
    conn = get_connection()
    if not conn:
        print("⚠️ DB connection failed when fetching chat history.")
        return []

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT chat_id, user_id, user_message, bot_response, emotion_detected, timestamp
            FROM chat_history
            WHERE user_id = %s
            ORDER BY timestamp DESC
            LIMIT %s
            """,
            (int(user_id), int(limit)),
        )
        rows = cursor.fetchall() or []

        # Convert to chronological order so clients can render top->bottom.
        rows.reverse()
        return rows
    except Error as e:
        print("❌ get_chat_history_by_user error:", e)
        return []
    finally:
        try:
            cursor.close()
        except Exception:
            pass
        conn.close()


def get_chat_session_summaries_by_user(user_id: int, days: int = 30):
    """Return per-day chat session summary counts for the user.

    We treat a 'session' as a calendar date (real-world enough for simple apps).
    Output rows:
      - session_date (YYYY-MM-DD)
      - message_pairs (count of rows in chat_history for that day)
      - last_message_ts
    """
    conn = get_connection()
    if not conn:
        print("⚠️ DB connection failed when fetching chat session summaries.")
        return []

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT
              DATE(timestamp) AS session_date,
              COUNT(*) AS message_pairs,
              MAX(timestamp) AS last_message_ts
            FROM chat_history
            WHERE user_id = %s
              AND timestamp >= DATE('now', '-' || %s || ' day')
            GROUP BY DATE(timestamp)
            ORDER BY DATE(timestamp) DESC
            """,
            (int(user_id), int(days)),
        )
        return cursor.fetchall() or []
    except Exception:
        # MySQL doesn't support SQLite's DATE('now', ...) form.
        # Fall back to a portable query that works in both engines.
        try:
            cursor.execute(
                """
                SELECT
                  DATE(timestamp) AS session_date,
                  COUNT(*) AS message_pairs,
                  MAX(timestamp) AS last_message_ts
                FROM chat_history
                WHERE user_id = %s
                GROUP BY DATE(timestamp)
                ORDER BY DATE(timestamp) DESC
                """,
                (int(user_id),),
            )
            rows = cursor.fetchall() or []
            return rows[: max(1, int(days))]
        except Error as e:
            print("❌ get_chat_session_summaries_by_user error:", e)
            return []
    finally:
        try:
            cursor.close()
        except Exception:
            pass
        conn.close()



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



        _insert_activity_logs_from_csv(conn, user_id=user_id, activities_csv=activities)

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


        cursor.execute("SELECT COUNT(*) FROM mood_logs WHERE user_id = %s", (user_id,))
        mood_count = cursor.fetchone()[0] or 0


        cursor.execute("SELECT COUNT(*) FROM journal_entries WHERE user_id = %s", (user_id,))
        journal_count = cursor.fetchone()[0] or 0


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


def _insert_activity_logs_from_csv(conn, *, user_id: int, activities_csv: str, timestamp=None):
    """Insert activity log rows from a CSV string into activity_logs.

    Uses the provided open connection and does NOT commit.
    """
    if not activities_csv:
        return


    raw_items = [s.strip() for s in str(activities_csv).split(',')]
    activity_types = [s for s in raw_items if s]
    if not activity_types:
        return

    cursor = conn.cursor()
    try:
        if timestamp is None:
            sql = """
                INSERT INTO activity_logs (user_id, activity_type)
                VALUES (%s, %s)
            """
            for activity_type in activity_types:
                cursor.execute(sql, (user_id, activity_type))
        else:
            sql = """
                INSERT INTO activity_logs (user_id, activity_type, timestamp)
                VALUES (%s, %s, %s)
            """
            for activity_type in activity_types:
                cursor.execute(sql, (user_id, activity_type, timestamp))
    finally:
        cursor.close()


def backfill_activity_logs_from_mood_logs(user_id: int, days: int = 30) -> int:
    """Backfill activity_logs from mood_logs for the given user.

    This is intentionally conservative: it only runs when the user has no
    activity_logs rows at all (to avoid duplicates).

    Returns number of activity rows inserted.
    """
    conn = get_connection()
    if not conn:
        return 0

    inserted = 0
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT COUNT(*) AS c FROM activity_logs WHERE user_id = %s",
            (user_id,),
        )
        row = cursor.fetchone() or {}
        if int(row.get('c') or 0) > 0:
            return 0

        cutoff = datetime.utcnow() - timedelta(days=int(days))
        cursor.execute(
            """
            SELECT activities, timestamp
            FROM mood_logs
            WHERE user_id = %s
              AND timestamp > %s
            ORDER BY timestamp ASC
            """,
            (user_id, cutoff),
        )
        mood_rows = cursor.fetchall() or []
        for r in mood_rows:
            before = inserted
            _insert_activity_logs_from_csv(
                conn,
                user_id=user_id,
                activities_csv=r.get('activities') or '',
                timestamp=r.get('timestamp'),
            )

            raw_items = [s.strip() for s in str(r.get('activities') or '').split(',')]
            inserted += len([s for s in raw_items if s])
            if inserted != before:
                pass

        conn.commit()
        return inserted
    except Error as e:
        print('❌ backfill_activity_logs_from_mood_logs error:', e)
        try:
            conn.rollback()
        except Exception:
            pass
        return 0
    finally:
        try:
            cursor.close()
        except Exception:
            pass
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
        cutoff = datetime.utcnow() - timedelta(days=int(days))
        cursor.execute(
            """
            SELECT
                COALESCE(detected_emotion, 'Unknown') AS emotion,
                COUNT(*) AS count,
                AVG(confidence_score) AS avg_confidence
            FROM face_detection_logs
            WHERE user_id = %s
              AND timestamp > %s
            GROUP BY emotion
            ORDER BY count DESC
            """,
            (user_id, cutoff),
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


def get_face_detection_logs(user_id, limit=50, days=30):
    """Return latest face detection log rows for the user.

    Output row keys:
      - detected_emotion
      - confidence_score
      - faces_detected
      - detection_method
      - timestamp
    """
    conn = get_connection()
    if not conn:
        print("⚠️ Could not fetch face detection logs — DB connection failed.")
        return []

    try:
        cursor = conn.cursor(dictionary=True)
        cutoff = datetime.utcnow() - timedelta(days=int(days))
        cursor.execute(
            """
            SELECT detected_emotion,
                   confidence_score,
                   faces_detected,
                   detection_method,
                   timestamp
            FROM face_detection_logs
            WHERE user_id = %s
              AND timestamp > %s
            ORDER BY timestamp DESC
            LIMIT %s
            """,
            (user_id, cutoff, int(limit)),
        )
        return cursor.fetchall() or []
    except Error as e:
        print("❌ get_face_detection_logs error:", e)
        return []
    finally:
        try:
            cursor.close()
        except Exception:
            pass
        conn.close()
