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
