import mysql.connector
from mysql.connector import Error
import config


def get_connection():
    try:
        conn = mysql.connector.connect(
            host=config.DB_CONFIG['host'],
            user=config.DB_CONFIG['user'],
            password=config.DB_CONFIG['password'],
            database=config.DB_CONFIG['database']
        )
        if conn.is_connected():
            print("✅ Database connected successfully.")
            return conn
        else:
            print("❌ Database connection failed.")
            return None
    except Error as e:
        print("❌ DB connection error:", e)
        return None


# helper: insert mood log
def insert_mood_log(user_id, text_entry, predicted_emotion):
    conn = get_connection()
    if not conn:
        print("⚠️ Could not insert mood log — DB connection failed.")
        return False
    try:
        cursor = conn.cursor()
        sql = """
            INSERT INTO mood_logs (user_id, text_entry, predicted_emotion)
            VALUES (%s, %s, %s)
        """
        cursor.execute(sql, (user_id, text_entry, predicted_emotion))
        conn.commit()
        print("🧠 Mood log inserted successfully.")
        return True
    except Error as e:
        print("❌ Insert mood log error:", e)
        return False
    finally:
        cursor.close()
        conn.close()


# insert a full mood log including mood label, energy, activities, and note
def insert_full_mood_log(user_id, mood_label, energy_level, activities, note):
    """Insert a detailed mood log. `activities` should be a JSON-serializable string (e.g. comma-separated or JSON array)."""
    conn = get_connection()
    if not conn:
        print("⚠️ Could not insert full mood log — DB connection failed.")
        return False
    try:
        cursor = conn.cursor()
        sql = """
            INSERT INTO mood_logs (user_id, mood_label, energy_level, activities, note)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(sql, (user_id, mood_label, energy_level, activities, note))
        conn.commit()
        print("🧾 Full mood log inserted successfully.")
        return True, None
    except Error as e:
        err = str(e)
        print("❌ Insert full mood log error:", err)
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
